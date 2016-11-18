startup_apply <- function(what = c("Renviron", "Rprofile"), all = FALSE) {
  what <- match.arg(what)
  if (what == "Renviron") {
    paths <- find_renviron_d(all = all)
    files <- find_d_files(paths)
    FUN <- readRenviron
  } else if (what == "Rprofile") {
    paths <- find_rprofile_d(all = all)
    files <- find_d_files(paths)
    FUN <- source
  }

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

  dryrun <- as.logical(Sys.getenv("R_STARTUP_DRYRUN", "FALSE"))
  dryrun <- getOption("startup.dryrun", dryrun)
  logf("startup: processing %d %s files", length(files), what)
  for (file in files) {
    logf(" - %s", file)
    if (!dryrun) FUN(file)
  }
  if (dryrun) log("(all files were skipped because startup.dryrun = TRUE)")

  invisible(files)
}
