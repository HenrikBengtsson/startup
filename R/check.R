#' Check for and fix common mistakes in .Rprofile
#'
#' Check for and fix common mistakes in \file{.Rprofile} files.
#;
#' @param all Should all or only the first entry on
#' [the R startup search path][base::Startup] be checked?
#'
#' @param fix If `TRUE`, detected issues will be tried to be automatically
#' fixed, otherwise not.
#'
#' @param backup If `TRUE`, a timestamped backup copy of the original file is
#' created before modifying it, otherwise not.
#'
#' @param debug If `TRUE`, debug messages are outputted, otherwise not.
#'
#' @return Returns invisibly a character vector of files that were "fixed"
#' (modified), if any.  If no files needed to be fixed, or `fix = TRUE`,
#' then an empty vector is returned.
#' 
#' @references
#' 1. R-devel thread 'Last line in .Rprofile must have newline (PR#4056)',
#'    2003-09-03,
#'    \url{https://stat.ethz.ch/pipermail/r-devel/2003-September/027457.html}
#'
#' @export
check <- function(all = FALSE, fix = TRUE, backup = TRUE, debug = FALSE) {
  debug(debug)
  
  updated <- check_rprofile_eof(all = all, fix = fix, backup = backup,
                                debug = debug)
  
  check_rprofile_update_packages(all = all, debug = debug)
  
  if (!fix) {
    log("All startup files checked. If there were files with issues, they were not corrected because fix = FALSE.")
  } else {
    if (length(updated) == 0L) {
      log("All startup files checked. No files were fixed.")
    } else {
      logf("All startup files checked. The following files were fixed (modified): %s", paste(squote(updated), collapse = ", "))
    }
  }
  
  invisible(updated)
}


check_rprofile_eof <- function(files = NULL, all = FALSE, fix = TRUE,
                               backup = TRUE, debug = FALSE) {
  updated <- character(0L)

  debug(debug)
  if (is.null(files)) files <- find_rprofile(all = all)

  for (kk in seq_along(files)) {
    file <- files[kk]
    if (!eof_ok(file)) {
      if (fix) {
        if (backup) backup(file)

        ## Try to fix it by appending a newline
        try(cat(file = file, "\n", append = TRUE))

        ## Record that the file was updated
        updated <- c(updated, file)
        
        if (eof_ok(file)) {
          msg <- sprintf("SYNTAX ISSUE FIXED: Added missing newline to the end of file %s, which otherwise would cause R to silently ignore the file in the startup process.", file)  #nolint
          warning("startup::check(): ", msg)
        } else {
          msg <- sprintf("SYNTAX ERROR: Tried to add missing newline to the end of file %s, which otherwise would cause R to silently ignore the file in the startup process, but failed.", file)  #nolint
          stop("startup::check(): ", msg)
        }
      } else {
        msg <- sprintf("SYNTAX ERROR: File %s is missing a newline at the end of the file, which most likely will cause R to silently ignore the file in the startup process.", file)  #nolint
        stop("startup::check(): ", msg)
      }
    }
  }

  invisible(updated)
}


check_rprofile_update_packages <- function(files = NULL, all = FALSE,
                                           debug = FALSE) {
  if (is.null(files)) {
    files <- find_rprofile(all = all)
    paths <- find_rprofile_d(all = all)
    files <- c(files, list_d_files(paths))
  }
  if (length(files) == 0) return()

  patterns <- c(
    "utils::update.packages()" = "update[.]packages[(][^)]*[)]",
    "pacman::p_up()" = "p_up[(][^)]*[)]"
  )

  for (file in files) {
    bfr <- readLines(file, warn = FALSE)
    bfr <- gsub("#.*", "", bfr, fixed = FALSE)

    for (name in names(patterns)) {
      pattern <- patterns[name]
      if (any(grepl(pattern, bfr, fixed = FALSE))) {
        msg <- sprintf("UNSAFE STARTUP CALL DETECTED (%s): Updating or installing R packages during R startup will recursively spawn off an infinite number of R processes. Please remove offending call in order for .Rprofile scripts to be applied: %s", name, file)  #nolint
        stop("startup::check(): ", msg)
      }
    }
  }
}


check_options <- function(include = c("encoding", "error", "stringsAsFactors"), exclude = NA) {
  include <- match.arg(include, several.ok = TRUE,
                       choices = c("encoding", "error", "stringsAsFactors"))
  if (length(include) == 0L) return()
  if (length(exclude) > 0L) {
    if (is.na(exclude)) {
      ignore <- Sys.getenv("R_STARTUP_CHECK_OPTIONS_IGNORE", "error")
      if (is.na(ignore)) ignore <- NULL
      exclude <- getOption("startup.check.options.ignore", ignore)
    }
    keep <- (match(include, table = exclude, nomatch = 0L) == 0L)
    include <- include[keep]
  }
  if (length(include) == 0L) return()

  msg <- function(opt, default, value, body = NULL) {
    msg <- sprintf("R option '%s' was changed (to '%s') during startup, cf. Startup.  Values other than the default '%s' is known to cause problems.", opt, value, default)
    msg <- c(msg, body)
    msg <- c(msg, sprintf("To disable this check, add \"%s\" to option 'startup.check.options.ignore'.", opt))
    paste("startup::check():", paste(msg, collapse = " "))
  }

  for (opt in include) {
    if (opt == "encoding") {
      value <- getOption(opt, default = NULL)
      default <- "native.enc"
      if (!interactive() && !is.null(value) && value != default) {
        unique_warning(msg(opt, default, value, body = "For example, in non-interactive sessions installation of packages with non-ASCII characters (also in source code comments) fails. To set the encoding only in interactive mode, e.g. if (base::interactive()) options(encoding = \"UTF-8\")."), call. = FALSE)
      }
    } else if (opt == "error") {
      check_rstudio_option_error_conflict()
    } else if (opt == "stringsAsFactors") {
      value <- getOption(opt, default = NULL)
      default <- if (getRversion() >= "4.0.0") FALSE else TRUE
      if (!is.null(value) && value != default) {
        unique_warning(msg(opt, default, value), call. = FALSE)
      }
    }
  }
}


check_envs <- function() {
  check_r_libs_env_vars()
}


check_r_libs_env_vars <- function() {
  vars <- c("R_LIBS", "R_LIBS_SITE", "R_LIBS_USER")
  for (var in vars) {
    path <- Sys.getenv(var)
    if (!nzchar(path)) next

    ## Ignore "NULL" as is the case in R 4.2.0?
    if (var != "R_LIBS") {
      if (path == "NULL") next
      
      ## SPECIAL CASE: The system Renviron file sets R_LIBS_USER="%U"
      ## and R_LIBS_SITE="%S", if not already set.  Then the system
      ## Rprofile file, expands and updates their values. It keeps
      ## the values regardless of them refering to existing folders.
      ## We don't want to warn about these non-existing defaults.

      if (var == "R_LIBS_USE") {
        if (path == .expand_R_libs_env_var("%U")) {
          if (!is_dir(path)) next
        }
      } else if (var == "R_LIBS_SITE") {
        if (path == .expand_R_libs_env_var("%S") &&
	    length(.Library.site) == 0) {
          if (!is_dir(path)) next
        }
      }
    }

    ## Don't check intential "dummy" specification, e.g.
    ## non-existing-dummy-folder
    is_dummy <- grepl("^[.]", path) && !grepl("[/\\]", path)
    if (is_dummy) next

    paths <- unlist(strsplit(path, split = .Platform$path.sep, fixed = TRUE))
    paths <- unique(paths)
    paths <- paths[!vapply(paths, FUN = is_dir, FUN.VALUE = FALSE)]

    npaths <- length(paths)
    if (npaths > 0) {
      pathsx <- normalizePath(paths, mustWork = FALSE)
      pathsq <- paste(squote(paths), collapse = ", ")
      if (!all(pathsx == paths)) {
        pathsq <- sprintf("%s (expands to %s)",
                          pathsq, paste(squote(pathsx), collapse = ", "))
      }
      pathsQ <- paste(sprintf("\"%s\"", paths), collapse = ", ")
      if (npaths == 1L) {
        msg <- sprintf("Environment variable %s specifies a non-existing folder %s which R ignores and therefore are not used in .libPaths(). To create this folder, call dir.create(%s, recursive = TRUE)", squote(var), pathsq, pathsQ)
      } else {
        msg <- sprintf("Environment variable %s specifies %d non-existing folders %s which R ignores and therefore are not used in .libPaths(). To create these folders, call sapply(c(%s), dir.create, recursive = TRUE)", squote(var), npaths, pathsq, pathsQ)
      }
      unique_warning("startup::check(): ", msg, call. = FALSE)
    }
  }

  vars <- c("R_PROFILE", "R_PROFILE_USER", "R_ENVIRON", "R_ENVIRON_USER")
  for (var in vars) {
    pathname <- Sys.getenv(var)
    if (!nzchar(pathname)) next
    
    if (!is_file(pathname)) {
      pathnameq <- squote(pathname)
      pathnamex <- normalizePath(pathname, mustWork = FALSE)
      if (pathnamex != pathname) {
        pathnameq <- sprintf("%s (expands to %s)", pathnameq, squote(pathnamex))
      }
      msg <- sprintf("Environment variable %s specifies a non-existing startup file %s which R will silently ignore", squote(var), pathnameq)
      unique_warning("startup::check(): ", msg, call. = FALSE)
    }
  }

  vars <- c(build = "R_BUILD_ENVIRON", check = "R_CHECK_ENVIRON")
  for (key in names(vars)) {
    var <- vars[key]
    pathname <- Sys.getenv(var)
    if (!nzchar(pathname)) next
    
    if (!is_file(pathname)) {
      pathnameq <- squote(pathname)
      pathnamex <- normalizePath(pathname, mustWork = FALSE)
      if (pathnamex != pathname) {
        pathnameq <- sprintf("%s (expands to %s)", pathnameq, squote(pathnamex))
      }
      msg <- sprintf("Environment variable %s specifies a non-existing startup file %s which 'R CMD %s' will silently ignore", squote(var), pathnameq, key)
      unique_warning("startup::check(): ", msg, call. = FALSE)
    }
  }
}


check_rstudio_option_error_conflict <- function() {
  ## Nothing to do?
  if (is.null(getOption("error")) || !is_rstudio_console()) return()

  ## Skip check if renv is active (because we cannot reliably test)
  ## https://github.com/HenrikBengtsson/startup/issues/76
  is_renv <- isTRUE(as.logical(Sys.getenv("RENV_R_INITIALIZING")))
  if (is_renv) return()

  ## If possible, detect when 'Debug -> On Error' is _not_ set in RStudio.
  ## If so, then skip the warning, because that is a case when RStudio Console
  ## does not override 'error'.
  config_root <- "~/.rstudio-desktop"
  if (!is_dir(config_root) && sysinfo()$os == "windows") {
    ## Officially documented root folder for RStudio configuration files
    ## Source: https://support.rstudio.com/hc/en-us/articles/200534577-Resetting-RStudio-Desktop-s-State
    
    ## Alternatives on (a) Windows Vista 7, 8, ... and (b) Windows XP
    config_root <- file.path(Sys.getenv("localappdata"), "RStudio-Desktop")
    if (!is_dir(config_root)) {
      config_root <- file.path(Sys.getenv("USERPROFILE"), "Local Settings",
                               "Application Data", "RStudio-Desktop")
    }
  }
  if (is_dir(config_root)) {
    ## Non-official configuration file found by reverse engineering only,
    ## cf. https://github.com/HenrikBengtsson/startup/issues/59
    config_file <- file.path(config_root, "monitored", "user-settings",
                             "user-settings")
    if (is_file(config_file)) {
      config <- readLines(config_file, warn = FALSE)
      ## 'Debug -> On Error' is _not_ set.  Nothing to warn about
      config <- grep("errorHandlerType=", config, fixed = TRUE, value = TRUE)
      if (length(config) == 0L) return()
      if (any(grepl("errorHandlerType=\"3\"", config, fixed = TRUE))) return()
    }
  }

  ## Record intended value of option 'error'
  options(startup.error.lost = getOption("error"))

  unique_warning("startup::check(): ", "CONFLICT: Option ", squote("error"), " was set during the R startup, but this will be overridden due to the RStudio settings (menu ", squote("Debug -> On Error"), ") when using the RStudio Console. To silence this warning, do not set option 'error' when running RStudio Console, e.g. ", squote("if (!startup::sysinfo()$rstudio) options(error = ...)"), ". The 'error' option that was set during the startup process but lost is recorded in option ", squote("startup.error.lost"), ". For further details on this issue, see https://github.com/rstudio/rstudio/issues/3007")
}


## Check that Renviron and Rprofile files are properly capitalized. The proper
## way is .Renviron and .Rprofile, whereas, for instance, .REnviron is not.
warn_file_capitalization <- function(pathname, what) {
  ## Get the actual name on file
  path <- dirname(pathname)
  file <- basename(pathname)
  pattern <- sprintf("^%s$", file)
  actual <- dir(path = path, pattern = pattern, ignore.case = TRUE, all.files = TRUE)
  if (length(actual) == 0) return(invisible(TRUE))
  if (length(actual) > 1) {
    warning(sprintf("startup::startup(): Unexpected, internal result. Please report to the %s maintainer. Found more than one %s file: %s", squote(.packageName), squote(what), paste(squote(actual), collapse = ", ")))
    actual <- actual[1]
  }
  
  ## Is it a non-standard file name?
  pattern <- sprintf("^[.]?%s", what)
  if (grepl(pattern, actual)) return(invisible(TRUE))

  ## Produce informative warning
  pathname_actual <- file.path(path, actual)
  correct <- gsub(pattern, sprintf(".%s", what), actual, ignore.case = TRUE)
  pathname_correct <- file.path(path, correct)
  msg <- sprintf("Detected non-standard, platform-dependent letter casing of an %s file. Please rename file to use the officially supported casing: %s -> %s", squote(what), squote(pathname_actual), squote(pathname_correct))
  warning("startup::startup(): ", msg, call. = FALSE)
  invisible(FALSE)
}



unique_warning <- local({
  msgs <- NULL
  function(...,  call. = TRUE) {
    msg <- .makeMessage(...)
    ## Nothing to do? Already warned?
    if (msg %in% msgs) return(invisible(msg))
    msgs <<- c(msgs, msg)
    warning(..., call. = call.)
  }
})
