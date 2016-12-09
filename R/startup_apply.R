startup_apply <- function(what = c("Renviron", "Rprofile"), sibling = FALSE, all = FALSE, on_error = c("error", "warning", "immediate.warning", "message", "ignore")) {
  what <- match.arg(what)
  on_error <- match.arg(on_error)
  if (what == "Renviron") {
    paths <- find_renviron_d(sibling = sibling, all = all)
    files <- find_d_files(paths)
    FUN <- readRenviron
  } else if (what == "Rprofile") {
    paths <- find_rprofile_d(sibling = sibling, all = all)
    files <- find_d_files(paths)
    FUN <- function(pathname, ...) {
      res <- tryCatch(source(pathname, ...), error = identity)
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
  sysinfo <- sysinfo()
  for (key in names(sysinfo)) {
    pattern <- sprintf(".*[^a-z]+%s=([^=,/]*).*", key)
    idxs <- grep(pattern, files, fixed = FALSE)
    if (length(idxs) > 0) {
      value <- sysinfo[[key]]
      values <- gsub(pattern, "\\1", files[idxs])
      drop <- idxs[values != value]
      if (length(drop) > 0) files <- files[-drop]
    }
  }

  ## Nothing to do?
  if (length(files) == 0) return(invisible(character(0)))
  
  dryrun <- as.logical(Sys.getenv("R_STARTUP_DRYRUN", "FALSE"))
  dryrun <- getOption("startup.dryrun", dryrun)
  logf("Processing %d %s files:", length(files), what)
  for (file in files) {
    logf(" - %s", file)
    if (!dryrun) FUN(file)
  }
  if (dryrun) log("(all files were skipped because startup.dryrun = TRUE)")

  invisible(files)
}
