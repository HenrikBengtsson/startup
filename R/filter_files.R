filter_files <- function(files, info = sysinfo()) {
  op <- "="
  
  ## Parse <key>=<value> and keep only matching ones
  for (key in c(names(info), "package")) {
    ## Identify files specifying this <key>=<value>
    pattern <- sprintf(".*[^a-z]*%s%s([^=,/]*).*", key, op)
    idxs <- grep(pattern, files, fixed = FALSE)
    if (length(idxs) == 0) next

    ## There could be more than one <key>=<name> specification
    ## per pathname that use the same <key>, e.g. package=nnn.
    files_tmp <- strsplit(files[idxs], split = ",", fixed = TRUE)
    files_tmp <- lapply(files_tmp, FUN = function(f) grep(pattern, f, value = TRUE))
    files_values <- lapply(files_tmp, FUN = function(f) gsub(pattern, "\\1", f))

    if (key == "package") {
      files_ok <- lapply(files_values, FUN = function(values) {
        ## Check which packages are installed and can be loaded
        keep <- lapply(values, FUN = requireNamespace, quietly = TRUE)
	keep <- unlist(keep, use.names = FALSE)
	if (op == "!=") keep <- !keep
        all(keep)
      })
      files_ok <- unlist(files_ok, use.names = FALSE)
      drop <- idxs[!files_ok]
    } else {
      ## sysinfo() keys
      value <- info[[key]]
      files_ok <- lapply(files_values, FUN = function(values) {
        keep <- (values == value)
	if (op == "!=") keep <- !keep
        all(keep)
      })
      files_ok <- unlist(files_ok, use.names = FALSE)
      drop <- idxs[!files_ok]
    }
    
    if (length(drop) > 0) files <- files[-drop]
  } ## for (key ...)

  files
} ## filter_files()
