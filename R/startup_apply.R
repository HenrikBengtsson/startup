startup_apply <- function(prefix, FUN, ..., debug = FALSE) {
  ol <- Sys.getlocale("LC_COLLATE")
  on.exit(Sys.setlocale("LC_COLLATE", ol))
  Sys.setlocale("LC_COLLATE", "C")

  ## (i) Initialization directory in current directory
  path <- file.path(".", sprintf("%s.d", prefix))
  files1 <- dir(path = path, pattern = "[^~]$", recursive = TRUE, all.files = TRUE, full.names = TRUE)
  
  ## (ii) Initialization directory in user's home directory
  path <- file.path("~", sprintf("%s.d", prefix))
  files2 <- dir(path = path, pattern = "[^~]$", recursive = TRUE, all.files = TRUE, full.names = TRUE)
  
  files <- c(files1, files2)
  files <- files[basename(files) != ".Rhistory"]
  files <- files[file.exists(files)]
  files <- files[!file.info(files)$isdir]
  files <- normalizePath(files)
  files <- unique(files)

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
  logf("startup: processing %d %s files", length(files), prefix)
  for (file in files) {
    logf(" - %s", file)
    if (!dryrun) FUN(file, ...)
  }
  if (dryrun) log("(all files were skipped because startup.dryrun = TRUE)")

  invisible(files)
}
