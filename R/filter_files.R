filter_files <- function(files, sysinfo = sysinfo()) {
  ## Parse <key>=<value> and keep only matching ones
  for (key in c(names(sysinfo), "package")) {
    ## Identify files specifying this <key>=<value>
    pattern <- sprintf(".*[^a-z]*%s=([^=,/]*).*", key)
    idxs <- grep(pattern, files, fixed = FALSE)
    if (length(idxs) == 0) next

    ## There could be more than one package=<name> specification
    ## per pathname.
    files_tmp <- strsplit(files[idxs], split = ",", fixed = TRUE)
    files_tmp <- lapply(files_tmp, FUN = function(f) grep(pattern, f, value = TRUE))
    files_values <- lapply(files_tmp, FUN = function(f) gsub(pattern, "\\1", f))

    if (key == "package") {
      files_ok <- lapply(files_values, FUN = function(pkgs) {
         ## Check which packages are installed and can be loaded
         avail <- lapply(pkgs, FUN = requireNamespace, quietly = TRUE)
	 all(unlist(avail, use.names = FALSE))
      })
      files_ok <- unlist(files_ok, use.names = FALSE)
      drop <- idxs[!files_ok]
    } else {
      ## sysinfo() keys
      value <- sysinfo[[key]]
      values <- gsub(pattern, "\\1", files[idxs])
      drop <- idxs[values != value]
    }
    
    if (length(drop) > 0) files <- files[-drop]
  } ## for (key ...)

  files
} ## filter_files()
