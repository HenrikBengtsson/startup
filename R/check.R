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
      logf("All startup files checked. The following files were fixed (modified): %s", paste(sQuote(updated), collapse = ", "))
    }
  }
  
  invisible(updated)
}


check_rprofile_eof <- function(files = NULL, all = FALSE, fix = TRUE,
                               backup = TRUE, debug = FALSE) {
  eof_ok <- function(file) {
    size <- file.info(file)$size
    ## On Windows, symbolic links give size = 0
    if (.Platform$OS.type == "windows" && size == 0L) size <- 1e9
    bfr <- readBin(file, what = "raw", n = size)
    n <- length(bfr)
    if (n == 0L) return(FALSE)
    is.element(bfr[n], charToRaw("\n\r"))
  }

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
          warning(msg)
        } else {
          msg <- sprintf("SYNTAX ERROR: Tried to add missing newline to the end of file %s, which otherwise would cause R to silently ignore the file in the startup process, but failed.", file)  #nolint
          stop(msg)
        }
      } else {
        msg <- sprintf("SYNTAX ERROR: File %s is missing a newline at the end of the file, which most likely will cause R to silently ignore the file in the startup process.", file)  #nolint
        stop(msg)
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
    "utils::update.packages()" = "update.packages[(][^)]*[)]",
    "pacman::p_up()" = "p_up[(][^)]*[)]"
  )

  for (file in files) {
    bfr <- readLines(file, warn = FALSE)
    bfr <- gsub("#.*", "", bfr, fixed = FALSE)

    for (name in names(patterns)) {
      pattern <- patterns[name]
      if (any(grepl(pattern, bfr, fixed = FALSE))) {
        msg <- sprintf("UNSAFE STARTUP CALL DETECTED (%s): Updating or installing R packages during R startup will recursively spawn off an infinite number of R processes. Please remove offending call in order for .Rprofile scripts to be applied: %s", name, file)  #nolint
        stop(msg)
      }
    }
  }
}


check_rprofile_encoding <- function(debug = FALSE) {
  if (isTRUE(getOption(".Rprofile.check.encoding", TRUE) &&
             !interactive() &&
             getOption("encoding", "native.enc") != "native.enc")) {
    msg <- sprintf("POTENTIAL STARTUP PROBLEM: Option 'encoding' seems to have been set (to '%s') during startup, cf. Startup.  Changing this from the default 'native.enc' is known to have caused problems, particularly in non-interactive sessions, e.g. installation of packages with non-ASCII characters (also in source code comments) fails. To disable this warning, set option '.Rprofile.check.encoding' to FALSE, or set the encoding conditionally, e.g. if (base::interactive()) options(encoding='UTF-8').", getOption("encoding"))  #nolint
    warning(msg)
  }
}



check_r_libs_env_vars <- function(debug = FALSE) {
  vars <- c("R_LIBS", "R_LIBS_SITE", "R_LIBS_USER")
  for (var in vars) {
    path <- Sys.getenv(var)
    if (nzchar(path)) {
      ## Don't check intential "dummy" specification, e.g.
      ## non-existing-dummy-folder
      is_dummy <- grepl("^[.]", path) && !grepl("[/\\]", path)
      if (!is_dummy) {
        paths <- unlist(strsplit(path, split = .Platform$path.sep, fixed = TRUE))
        paths <- unique(paths)
        paths <- paths[!is_dir(paths)]
        npaths <- length(paths)
        if (npaths > 0) {
          pathsx <- normalizePath(paths, mustWork = FALSE)
          pathsq <- paste(sQuote(paths), collapse = ", ")
          pathsQ <- paste(sprintf("\"%s\"", paths), collapse = ", ")
          pathsxq <- paste(sQuote(pathsx), collapse = ", ")
          if (npaths == 1L) {
            msg <- sprintf("Environment variable %s specifies a non-existing folder %s (expands to %s) which R ignores and therefore are not used in .libPaths(). To create this folder, call dir.create(%s, recursive = TRUE)", sQuote(var), pathsq, pathsxq, pathsQ)
          } else {
            msg <- sprintf("Environment variable %s specifies %d non-existing folders %s (expands to %s) which R ignores and therefore are not used in .libPaths(). To create these folders, call sapply(c(%s), dir.create, recursive = TRUE)", sQuote(var), npaths, pathsq, pathsxq, pathsQ)
          }
          warning(msg)
        }
      }
    }
  }
}


check_rstudio_option_error_conflict <- function(debug = FALSE) {
  ## Nothing to do?
  if (is.null(getOption("error")) || !is_rstudio_console()) return()

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
      if (!any(grepl("errorHandlerType", config))) return()
    }
  }
  
  warning("CONFLICT: Option ", sQuote("error"), " was set during the R startup, but this will be overridden by the RStudio setting (menu ", sQuote("Debug -> On Error"), ") when using the RStudio Console. To silence this warning, set option 'error' using ", sQuote("if (!startup::sysinfo()$rstudio) options(error = ...)"), ". For further details on this issue, see https://github.com/rstudio/rstudio/issues/3007")
}
