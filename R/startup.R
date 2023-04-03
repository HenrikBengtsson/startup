#' Load .Renviron.d and .Rprofile.d directories during the R startup process
#'
#' Initiates \R using all files under \file{.Renviron.d/} and / or
#' \file{.Rprofile.d/} directories (or in subdirectories thereof).
#'
#' The above is done in addition the \file{.Renviron} and \file{.Rprofile}
#' files that are supported by the built-in [startup process][base::Startup]
#' of \R.
#'
#' @param sibling If `TRUE`, then only \file{.Renviron.d/} and
#' \file{.Rprofile.d/} directories with a sibling \file{.Renviron} and
#' \file{.Rprofile} in the same location will be considered.
#'
#' @param all If `TRUE`, then _all_ \file{.Renviron.d/} and \file{.Rprofile.d/}
#' directories found on [the R startup search path][base::Startup] are
#' processed, otherwise only the _first ones_ found.
#'
#' @param on_error Action taken when an error is detected when sourcing an
#' Rprofile file.  It is not possible to detect error in Renviron files;
#' they are always ignored with a message that cannot be captured.
#'
#' @param keep Specify what information should remain after this function
#' complete.  The default is to keep `startup.session.*` options
#' as recorded by [startup_session_options()].
#'
#' @param check If `TRUE`, then the content of startup files are validated.
#' 
#' @param unload If `TRUE`, then the package is unloaded afterward, otherwise
#' not.
#'
#' @param skip If `TRUE`, startup directories will be skipped.  If `NA`, they
#' will be skipped if command-line options `--vanilla`, `--no-init-file`,
#' and / or `--no-environ` were specified.
#'
#' @param dryrun If `TRUE`, everything is done except the processing of the
#' startup files.
#'
#' @param debug If `TRUE`, debug messages are outputted, otherwise not.
#'
#' @section User-specific installation:
#' In order for \file{.Rprofile.d} and \file{.Renviron.d} directories to be
#' included during the \R startup process, a user needs to add
#' `startup::startup()` to \file{~/.Rprofile}.  Adding this can also be done
#' by calling [startup::install()] once.
#'
#' @section Site-wide installation:
#' An alternative to having each user add `startup::startup()` in their own
#' \file{~/.Rprofile} file, is to add it to the site-wide \file{Rprofile.site}
#' file (see [?Startup][base::Startup]).
#' The advantage of such a site-wide installation, is that the users do not
#' have to have a \file{.Rprofile} file for \file{.Rprofile.d} and
#' \file{.Renviron.d} directories to work.
#' For this to work for all users automatically, the \pkg{startup} package
#' should also be installed in the site-wide library.
#'
#' @examples
#' \dontrun{
#' # The most common way to use the package is to add
#' # the following call to the ~/.Rprofile file.
#' startup::startup()
#'
#' # To process ~/.Renviron.d/ files, and then any ./.Renviron.d/ files,
#' # followed by  ~/.Rprofile.d/ files, and then any ./.Rprofile.d/ files,
#' # add the following call to the ~/.Rprofile file.
#' startup::startup(all = TRUE)
#'
#' # For finer control of on exactly what files are used
#' # functions renviron_d() and rprofile_d() are also available:
#'
#' # Initiate first .Renviron.d/ found on search path
#' startup::renviron_d()
#'
#' # Initiate all .Rprofile.d/ directories found on the startup search path
#' startup::rprofile_d(all = TRUE)
#' }
#'
#' @describeIn startup `renviron_d()` followed by `rprofile_d()` and then the
#' package is unloaded
#' @export
startup <- function(sibling = FALSE, all = FALSE,
                    on_error = c("error", "warning", "immediate.warning",
                                 "message", "ignore"),
                    keep = c("options"), check = NA, unload = TRUE, skip = NA,
                    dryrun = NA, debug = dryrun) {
  ## Is startup::startup() fully disabled?
  disable <- as.logical(Sys.getenv("R_STARTUP_DISABLE", "FALSE"))
  disable <- getOption("startup.disable", disable)
  if (isTRUE(disable)) {
    return(invisible())
  }

  on_error <- match.arg(on_error)
  if (length(keep) > 0) keep <- match.arg(keep, several.ok = TRUE)

  if (is.na(check)) {
    check <- as.logical(Sys.getenv("R_STARTUP_CHECK", "TRUE"))
    check <- isTRUE(getOption("startup.check", check))
  }
  
  debug(debug)

  cmd_args <- getOption("startup.commandArgs", commandArgs())

  debug <- debug()
  if (debug) {
    r_home <- R.home()
    r_arch <- .Platform$r_arch
    r_os <- .Platform$OS.type

    logf("System information:")
    logf("- R_HOME: %s", path_info(Sys.getenv("R_HOME")))
    logf("- R call: %s", paste(cmd_args, collapse = " "))
    logf("- Current directory: %s", squote(getwd()))
    logf("- User's home directory: %s", path_info("~"))
    logf("- User's %s config directory: %s", squote(.packageName), path_info(get_user_dir("config")))
    logf("- Search path: %s", paste(squote(search()), collapse = ", "))
    logf("- Loaded namespaces: %s",
         paste(squote(loadedNamespaces()), collapse = ", "))

    logf("The following has already been processed by R:")

    logf("- R_ENVIRON: %s", file_info(Sys.getenv("R_ENVIRON"), type = "env", validate = TRUE))
    logf("- R_ENVIRON_USER: %s", file_info(Sys.getenv("R_ENVIRON_USER"), type = "env", validate = TRUE))
    
    if (r_os == "unix") {
      f <- file.path(r_home, "etc", "Renviron")
      if (is_file(f)) logf("- %s", file_info(f, type = "env", validate = TRUE))
    }

    no_environ <- any(c("--no-environ", "--vanilla") %in% cmd_args)
    if (!no_environ) {
      f <- Sys.getenv("R_ENVIRON")
      if (nzchar(r_arch) && !is_file(f)) {
        f <- file.path(r_home, "etc", r_arch, "Renviron.site")
      }
      if (!is_file(f)) f <- file.path(r_home, "etc", "Renviron.site")
      if (is_file(f)) logf("- %s", file_info(f, type = "env", validate = TRUE))

      f <- Sys.getenv("R_ENVIRON_USER")
      if (is_file(f)) {
        logf("- %s", file_info(f, type = "env", validate = TRUE))
      } else {
        if (nzchar(r_arch) && !is_file(f)) f <- sprintf(".Renviron.%s", r_arch)
        f <- ".Renviron"
        if (nzchar(r_arch) && !is_file(f)) f <- sprintf("~/.Renviron.%s", r_arch)
        if (!is_file(f)) f <- "~/.Renviron"
        if (is_file(f)) {
          logf("- %s", file_info(f, type = "env", validate = TRUE))
          warn_file_capitalization(f, "Renviron")
        }
      }
    }

    ## TMPDIR et al. may be set at the latest in an Renviron file
    logf("- tempdir(): %s", path_info(tempdir()))
    for (name in c("TMPDIR", "TMP", "TEMP")) {
      value <- Sys.getenv(name, "")
      logf("  - %s: %s", name, sQuote(value))
    }

    logf("- R_LIBS: %s", squote(Sys.getenv("R_LIBS")))
    logf("- R_LIBS_SITE: %s", squote(Sys.getenv("R_LIBS_SITE")))
    logf("- R_LIBS_USER: %s", squote(Sys.getenv("R_LIBS_USER")))

    pkgs <- Sys.getenv("R_SCRIPT_DEFAULT_PACKAGES")
    logf("- R_SCRIPT_DEFAULT_PACKAGES (only if Rscript was used): %s", squote(pkgs))
    
    pkgs <- Sys.getenv("R_DEFAULT_PACKAGES")
    if (pkgs == "") {
      ## In R (< 3.5.0), the 'methods' package is _not_ attached when Rscript
      ## is used.  In R (>= 3.5.0), the 'methods' package is always attached
      ## by default.  If attached, the 'methods' package is attached at the
      ## very beginning when R is started moments after the 'base' package is
      ## attached.  This is contrary to all other packages which are attached
      ## below.
      if (getRversion() < "3.5.0" && is_rscript()) {
        pkgs <- "base,datasets,utils,grDevices,graphics,stats"
      } else {
        pkgs <- "base,methods,datasets,utils,grDevices,graphics,stats"
      }
      logf("- R_DEFAULT_PACKAGES: %s (= %s)", squote(""), squote(pkgs))
    } else {
      logf("- R_DEFAULT_PACKAGES: %s", squote(pkgs))
    }

    f <- system.file("R", "Rprofile", package = "base")
    if (is_file(f)) logf("- %s", file_info(f, type = "r"))

    logf("- R_PROFILE: %s", file_info(Sys.getenv("R_PROFILE")))
    no_site_file <- any(c("--no-site-file", "--vanilla") %in% cmd_args)
    if (!no_site_file) {
      f <- Sys.getenv("R_PROFILE")
      if (is_file(f)) {
        logf("- %s", file_info(f, type = "r", validate = TRUE))
      } else {
        if (nzchar(r_arch)) f <- file.path(r_home, "etc", r_arch, "Rprofile.site")
        if (!is_file(f)) f <- file.path(r_home, "etc", "Rprofile.site")
        if (is_file(f)) {
          logf("- %s", file_info(f, type = "r"))
          warn_file_capitalization(f, "Rprofile")
        }
      }
    }

    logf("- R_PROFILE_USER: %s", file_info(Sys.getenv("R_PROFILE_USER")))
    no_init_file <- any(c("--no-init-file", "--vanilla") %in% cmd_args)
    if (!no_init_file) {
      f <- Sys.getenv("R_PROFILE_USER")
      if (is_file(f)) {
        logf("- %s", file_info(f, type = "r", validate = TRUE))
      } else {
        if (nzchar(r_arch)) f <- sprintf(".Rprofile.%s", r_arch)
        if (!is_file(f)) f <- ".Rprofile"
        if (nzchar(r_arch) && !is_file(f)) f <- sprintf("~/.Rprofile.%s", r_arch)
        if (!is_file(f)) f <- "~/.Rprofile"
        if (is_file(f)) {
          logf("- %s", file_info(f, type = "r"))
          warn_file_capitalization(f, "Rprofile")
        }
      }
    }

    f <- Sys.getenv("R_TESTS")
    if (nzchar(f)) {
      if (is_file(f)) {
        logf("- R_TESTS: %s", file_info(f, type = "r"))
      } else {
        logf("- R_TESTS: %s (not found)", normalizePath(f, mustWork = FALSE))
      }
    }

    if (.Platform$GUI == "Rgui") {
      paths <- c(system = file.path(Sys.getenv("R_HOME"), "etc"), user = Sys.getenv("R_USER"))
      for (name in names(paths)) {
        path <- paths[[name]]
        if (!is_dir(path)) next
        f <- file.path(path, "Rconsole")
        if (is_file(f)) {
          logf("- %s-specific Rconsole configuration: %s", name, file_info(f, type = "r"))
        } else {
          logf("- %s-specific Rconsole configuration: %s (not found)", name, normalizePath(f, mustWork = FALSE))
        }
      } ## for (path ...)
    }
  }

  logf("startup::startup()-specific processing ...")

  # (i) Load custom .Renviron.d/* files
  renviron_d(sibling = sibling, all = all, skip = skip, dryrun = dryrun)

  # (ii) Load custom .Rprofile.d/* files
  rprofile_d(sibling = sibling, all = all, check = check, skip = skip,
             dryrun = dryrun, on_error = on_error)


  ## (iv) Detect and report on run-time startup issues
  if (check) {
    # (a) Check for unsafe/non-intended changes to environment variables
    #     to library, Renviron, or Rprofile paths
    check_envs()
    
    # (b) Check for unsafe changes to R options changes done by
    #     any Rprofile files
    check_options()
  }

  ## (iii) Process R_STARTUP_INIT code?
  code <- Sys.getenv("R_STARTUP_INIT")
  code <- getOption("startup.init", code)
  if (nzchar(code)) {
    logf("Processing R_STARTUP_INIT/startup.init=%s:", squote(code))
    expr <- tryCatch(parse(text = code), error = identity)
    if (inherits(expr, "error")) {
      msg <- sprintf("Syntax error in 'R_STARTUP_INIT'/'startup.init': %s", squote(code))
      logf(paste("- [SKIPPED]", msg))
      if (on_error == "error") {
        stop(msg, call. = FALSE)
      } else if (on_error == "warning") {
        warning(msg, call. = FALSE)
      } else if (on_error == "immediate.warning") {
        warning(msg, immediate. = TRUE, call. = FALSE)
      } else if (on_error == "message") {
        message(msg)
      }
    } else {
      eval(expr, envir = .GlobalEnv, enclos = baseenv())
    }
  }

  ## (iv) Detect and report on run-time startup issues
  if (check) {
    check_envs()
    check_options()
  }
  
  ## (iii) Process R_STARTUP_FILE code?
  f <- Sys.getenv("R_STARTUP_FILE")
  f <- getOption("startup.file", f)
  if (nzchar(f)) {
    logf("Processing R_STARTUP_FILE/startup.file=%s:", squote(f))
    if (!is_file(f)) {
      msg <- sprintf("No such file 'R_STARTUP_FILE'/'startup.file' file: %s", squote(f))
      logf(paste("- [SKIPPING]", msg))
      if (on_error == "error") {
        stop(msg, call. = FALSE)
      } else if (on_error == "warning") {
        warning(msg, call. = FALSE)
      } else if (on_error == "immediate.warning") {
        warning(msg, immediate. = TRUE, call. = FALSE)
      } else if (on_error == "message") {
        message(msg)
      }
    }
    expr <- tryCatch(parse(file = f), error = identity)
    if (inherits(expr, "error")) {
      msg <- sprintf("Syntax error in 'R_STARTUP_INIT'/'startup.init': %s", squote(code))
      logf(paste("- [SKIPPED]", msg))
      if (on_error == "error") {
        stop(msg, call. = FALSE)
      } else if (on_error == "warning") {
        warning(msg, call. = FALSE)
      } else if (on_error == "immediate.warning") {
        warning(msg, immediate. = TRUE, call. = FALSE)
      } else if (on_error == "message") {
        message(msg)
      }
    } else {
      eval(expr, envir = .GlobalEnv, enclos = baseenv())
    }
  }

  ## (iv) Detect and report on run-time startup issues
  if (check) {
    check_envs()
    check_options()
  }
  
  res <- api()

  ## (v) Cleanup?
  if (!"options" %in% keep) startup_session_options(action = "erase")

  # (vi) Unload package?
  if (unload) {
    if (debug) logf("- unloading the %s package", squote(.packageName))
    on.exit(unload(debug = FALSE))
  }

  if (debug) {
    values <- search()
    if (unload) values <- setdiff(values, sprintf("package:%s", .packageName))
    logf("- Search path: %s", paste(squote(values), collapse = ", "))
    values <- loadedNamespaces()
    if (unload) values <- setdiff(values, .packageName)
    logf("- Loaded namespaces: %s", paste(squote(values), collapse = ", "))
    logf("startup::startup()-specific processing ... done")
    logf("The following will be processed next by R:")
  }

  no_restore_data <- any(c("--no-restore-data", "--no-restore", "--vanilla") %in% cmd_args)
  loads_RData <- has_RData <- FALSE
  if (!no_restore_data) {
    has_RData <- is_file(f <- "./.RData")
    if (has_RData) {
      f_norm <- normalizePath(f)
      f_info_short <- file_info(f, type = "binary")
      f_info <- file_info(f_norm, type = "binary")
      rdata <- Sys.getenv("R_STARTUP_RDATA", "")
      rdata <- getOption("startup.rdata", rdata)
      rdata0 <- rdata
      if (length(rdata) == 0L || rdata == "") {
        rdata <- "default"
      } else if (debug) {
        logf("- R_STARTUP_RDATA/startup.rdata=%s", paste(rdata, collapse = ","))
      }

      ## Support R_STARTUP_RDATA/startup.rdata=prompt,rename
      rdata <- unlist(strsplit(rdata, split = ",", fixed = TRUE))
      stopifnot(length(rdata) >= 1L, length(rdata) <= 2L)
      
      if (rdata[1] == "prompt") {
        fallback <- rdata[2L]
        if (interactive()) {  
          if (is.na(fallback) || fallback == "default") fallback <- "rename"
          if (debug) logf("- Prompting user whether they want to load or %s %s", fallback, f_info)
          question <- sprintf("Detected %s - do you want to load it? If not, it will be %sd.", f_info, fallback)

          ## We might be able to prompt the user
          if (is_rstudio_console() && !supports_tcltk()) {
            rdata <- "default"
            if (debug) logf("- Cannot prompt user in the RStudio Console on this system")
            warning(sprintf("Detected %s, which was loaded (default), because it was possible to ask you if it should loaded or not. The reason for this is that your R setup does not support X11 or tcltk, which is needed in order to prompt someone in the RStudio Console.", f_info, rdata0), call. = FALSE)
          } else {
            res <- ask_yes_no(question)
            if (debug) logf("- User wants to load it: %s", res)
            rdata <- if (res) "default" else fallback
          }  
        } else {
          ## Non-interactive session; it is not possible to the prompt user.
          if (length(rdata) == 1L) {
            rdata <- "default"
            warning(sprintf("Loading %s because it is not possible to prompt the user in a non-interactive session [R_STARTUP_RDATA/startup.rdata=%s]", f_info, rdata0), call. = FALSE)
          } else {
            ## Use fallback
            stop_if_not(!is.na(fallback))
            rdata <- fallback
          }
        }
      }

      ## At this point, we should have at most one element in 'rdata'
      stop_if_not(length(rdata) == 1L, !is.na(rdata))
      
      if (rdata == "remove") {
        if (debug) logf("- Skipping %s by removing it", f_info)
        file.remove(f)
        has_RData <- is_file(f)
        if (!has_RData) {
          warning(sprintf("Skipped %s by removing it [R_STARTUP_RDATA/startup.rdata=%s]", f_info, rdata0), call. = FALSE)
        }
      } else if (rdata == "rename") {
        fi <- file.info(f)
        when <- fi[c("mtime", "ctime")]
        keep <- vapply(when, FUN = inherits, "POSIXct", FUN.VALUE=FALSE)
        when <- when[keep]
        when <- sort(when, decreasing = TRUE)
        when <- format(when[[1]], format = "%Y%m%d_%H%M%S")
        f_new <- sprintf("%s.%s", f, when)
        file.rename(f, f_new)
        f_new_info <- file_info(normalizePath(f_new), type = "binary")
        if (debug) logf("- Skipping %s by renaming it to %s", f, f_new_info)
        has_RData <- is_file(f)
        if (!has_RData) {
          warning(sprintf("Skipped %s by renaming it to %s [R_STARTUP_RDATA/startup.rdata=%s]", squote(f_norm), f_new_info, rdata0), call. = FALSE)
        }
      } else if (rdata != "default") {
        warning(sprintf("Ignoring unknown value (%s) of %s/%s",
                        squote(rdata0), squote("R_STARTUP_RDATA"),
                        squote("startup.rdata")),
                call. = FALSE)
      }
    }
  }

  if (debug) {
    if (!no_restore_data) {
      if (has_RData) {
        loads_RData <- TRUE
        logf("- %s", file_info(f, type = "binary"))
      }
    }

    logf("- R_HISTFILE: %s", squote(Sys.getenv("R_HISTFILE")))
    no_restore_history <- any(c("--no-restore-history", "--no-restore", "--vanilla") %in% cmd_args)
    if (!no_restore_history && interactive()) {
      if (is_file(f <- Sys.getenv("R_HISTFILE", "./.Rhistory"))) {
        logf("- %s", file_info(f, type = "txt"))
      }
    }

    where <- find(".First", mode = "function")
    if (where > 0) {
      logf("- .First(): in %s (position %d on search())", squote(search()[where]), where)
    } else if (loads_RData) {
      logf("- .First(): no such function on search(), but it might be that one is defined in the ./RData file")
    } else {
      logf("- .First(): no such function on search()")
    }

    pkgs <- unlist(strsplit(pkgs, split = ",", fixed = TRUE))
    to_be_attached <- !is.element(paste("package:", pkgs, sep = ""), search())
    pkgs <- pkgs[to_be_attached]
    logf("- Remaining packages per R_DEFAULT_PACKAGES to be attached by base::.First.sys() (in order): %s",
         paste(squote(pkgs), collapse = ", "))

    
    logf("The following will be processed when R terminates:")
    for (what in c(".Last", ".Last.sys")) {
      where <- find(what, mode = "function")
      if (where > 0) {
        logf("- %s(): in %s (position %d on search()); circumvented by quit(runLast = FALSE)", what, squote(search()[where]), where)
      } else {
        logf("- %s(): no such function on search()", what)
      }
    }
  }

  invisible(res)
}
