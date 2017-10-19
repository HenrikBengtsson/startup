files_apply <- function(files, fun,
                        on_error = c("error", "warning", "immediate.warning",
                                     "message", "ignore"),
                        dryrun = NA, what = "Rprofile") {
  stopifnot(is.function(fun))
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
  logf("Processing %d %s files ... done", length(files), what)
  if (dryrun) log("(all files were skipped because startup.dryrun = TRUE)")

  invisible(files)
}
