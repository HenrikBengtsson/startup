startup_apply <- function(what = c("Renviron", "Rprofile"), sibling = FALSE, all = FALSE, print.eval = TRUE, on_error = c("error", "warning", "immediate.warning", "message", "ignore")) {
  what <- match.arg(what)
  on_error <- match.arg(on_error)
  if (what == "Renviron") {
    paths <- find_renviron_d(sibling = sibling, all = all)
    files <- list_d_files(paths)
    FUN <- readRenviron
  } else if (what == "Rprofile") {
    paths <- find_rprofile_d(sibling = sibling, all = all)
    files <- list_d_files(paths)
    FUN <- function(pathname) {
      res <- tryCatch(source(pathname, print.eval = print.eval), error = identity)
      if (inherits(res, "error")) {
        msg <- conditionMessage(res)
	msg <- sprintf("Failure running startup script %s: %s", sQuote(pathname), msg)
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

  ## Nothing to do?
  if (length(files) == 0) return(invisible(character(0)))

  ## Parse <key>=<value> and keep only matching ones
  nfiles <- length(files)
  files <- filter_files(files)

  ## Nothing to do?
  if (length(files) == 0) return(invisible(character(0)))
  
  dryrun <- as.logical(Sys.getenv("R_STARTUP_DRYRUN", "FALSE"))
  dryrun <- getOption("startup.dryrun", dryrun)
  nfiles <- length(files)
  logf("Processing %d %s files ...", nfiles, what)
  for (file in files) {
    logf(" - %s", file)
    if (!dryrun) FUN(file)
  }
  logf("Processing %d %s files ... done", nfiles, what)
  if (dryrun) log("(all files were skipped because startup.dryrun = TRUE)")

  invisible(files)
}
