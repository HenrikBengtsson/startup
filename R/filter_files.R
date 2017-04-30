filter_files <- function(files, info = sysinfo()) {
  for (op in c("=", "!=")) {
    ## Parse <key>=<value> and keep only matching ones
    for (key in c(names(info), "package")) {
      ## Identify files specifying this <key>=<value>
      pattern <- sprintf(".*[^a-z]*%s%s([^=,/]*).*", key, op)
      idxs <- grep(pattern, files, fixed = FALSE)
      if (length(idxs) == 0) next

      ## There could be more than one <key>=<name> specification
      ## per pathname that use the same <key>, e.g. package=nnn.
      files_tmp <- files[idxs]
      files_tmp <- gsub("[.](r|R)$", "", files_tmp)
      files_tmp <- strsplit(files_tmp, split = ",", fixed = TRUE)
      files_tmp <- lapply(files_tmp, FUN = function(f) {
        grep(pattern, f, value = TRUE)
      })
      files_values <- lapply(files_tmp, FUN = function(f) {
        gsub(pattern, "\\1", f)
      })

      if (key == "package") {
        files_ok <- lapply(files_values, FUN = function(values) {
          ## Check which packages are installed and can be loaded
          keep <- lapply(values, FUN = is_package_installed)
          keep <- unlist(keep, use.names = FALSE)
          if (op == "!=") keep <- !keep
          all(keep)
        })
        files_ok <- unlist(files_ok, use.names = FALSE)
        drop <- idxs[!files_ok]
      } else {
        ## sysinfo() keys
        value <- info[[key]]
        if (is.logical(value)) {
          files_values <- toupper(files_values)
          files_values[files_values == "1"] <- "TRUE"
          files_values[files_values == "0"] <- "FALSE"
          files_values <- as.logical(files_values)
          files_values[is.na(files_values)] <- FALSE
        }
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
  } ## for (op ...)

  files
} ## filter_files()


is_package_installed <- local({
  cache <- list()
  function(pkg) {
    res <- cache[[pkg]]
    if (is.logical(res)) return(res)
    res <- (length(find.package(package = pkg, lib.loc = .libPaths(),
                                quiet = TRUE)) > 0)
    cache[[pkg]] <<- res
    res
  }
})
