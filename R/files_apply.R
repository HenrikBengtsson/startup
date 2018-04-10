files_apply <- function(files, fun,
                        on_error = c("error", "warning", "immediate.warning",
                                     "message", "ignore"),
                        dryrun = NA, what = "Rprofile") {
  stop_if_not(is.function(fun))
  on_error <- match.arg(on_error)

  ## Nothing to do?
  if (length(files) == 0) return(invisible(character(0)))

  ## How should the files be processed?
  if (is.na(dryrun)) {
    dryrun <- as.logical(Sys.getenv("R_STARTUP_DRYRUN", "FALSE"))
    dryrun <- getOption("startup.dryrun", dryrun)
  }

  if (isTRUE(dryrun)) {
    call_fun <- function(pathname) NULL
  } else {
    call_fun <- function(pathname) {
      res <- tryCatch(fun(pathname), error = identity)
      if (inherits(res, "error")) {
        msg <- conditionMessage(res)
        msg <- sprintf("Failure processing startup file %s: %s",
                       sQuote(pathname), msg)
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
    }
  }

  logf("Processing %d %s files ...", length(files), what)
  if (what == "Renviron") {
    type <- "env"
  } else {
    type <- "r"
  }

  for (file in files) {
    logf(" - %s", file_info(file, type = type))
    call_fun(file)
  }

  unknown_keys <- attr(files, "unknown_keys")
  if (length(unknown_keys) > 0) {
    unknown_files <- names(unknown_keys)
##    for (file in unknown_files) {
##      keys <- unknown_keys[[file]]
##      reason <- sprintf("non-declared keys: %s",
##                        paste(sQuote(keys), collapse = ", "))
##      logf(" - [SKIPPED] %s", file_info(file, type = type, extra = reason))
##    }
    unknown_keys <- sort(unique(unlist(unknown_keys)))
    logf(" [WARNING] skipped %d files with non-declared key names (%s)", length(unknown_files), paste(sQuote(unknown_keys), collapse = ", "))
    if (getOption("startup.onskip", Sys.getenv("R_STARTUP_ONSKIP", "warn")) == "warn") {
      warning(sprintf("The 'startup' package skipped %d files with non-declared key names (%s). This is a new behavior since startup (>= 0.10.0) - previously, these files would be processed also when those keys where undefined. This warning will disappear in startup (>= 0.11.0) - to disable it already now, set environment variable R_STARTUP_ONSKIP=ignore or option 'startup.onskip=\"ignore\"': %s", length(unknown_files), paste(sQuote(unknown_keys), collapse = ", "), paste(sQuote(unknown_files), collapse = ", ")), immediate. = TRUE)
    }
  }
  
  logf("Processing %d %s files ... done", length(files), what)
  if (dryrun) log("(all files were skipped because startup.dryrun = TRUE)")

  invisible(files)
}
