startup_apply <- function(dir, FUN, ..., paths = c(".", "~")) {
  fileext <- function(x) {
    pos <- regexpr("\\.([[:alnum:]]+)$", x)
    ifelse(pos < 0, "", substring(x, pos + 1L))
  }

  ol <- Sys.getlocale("LC_COLLATE")
  on.exit(Sys.setlocale("LC_COLLATE", ol))
  Sys.setlocale("LC_COLLATE", "C")
  
  ## Directories to look for
  paths <- file.path(paths, dir)
  
  ## Keep only the ones that exists
  paths <- paths[file.exists(paths)]

  ## Nothing to do?
  if (length(paths) == 0) return(character(0L))
  
  ## For each directory, locate files of interest
  files <- NULL
  for (path in paths) {
    files <- c(files, dir(path = path, pattern = "[^~]$", recursive = TRUE, all.files = TRUE, full.names = TRUE))
  }

  ## Drop stray files
  files <- files[!is.element(basename(files), c(".Rhistory", ".RData"))]

  ## Drop files based on filename extension
  files <- files[!is.element(fileext(files), c("txt", "md"))]

  ## Keep only existing files
  files <- files[file.exists(files)]
  files <- files[!file.info(files)$isdir]

  ## Drop duplicates
  files <- normalizePath(files)
  files <- unique(files)

  ## Nothing to do?
  if (length(files) == 0) return(character(0L))

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
  logf("startup: processing %d %s files", length(files), dir)
  for (file in files) {
    logf(" - %s", file)
    if (!dryrun) FUN(file, ...)
  }
  if (dryrun) log("(all files were skipped because startup.dryrun = TRUE)")

  invisible(files)
}
