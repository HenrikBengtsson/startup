list_of_values <- function(files, pattern, names = FALSE) {
  if (length(files) == 0) return(list())
  files <- gsub("[.](r|R)$", "", files)
  files <- strsplit(files, split = "[,/]", fixed = FALSE)
  files <- lapply(files, FUN = function(f) grep(pattern, f, value = TRUE))
  if (names) {
    lapply(files, FUN = function(f) {
      values <- gsub(pattern, "\\2", f)
      names(values) <- gsub(pattern, "\\1", f)
      values
    })
  } else {
    lapply(files, FUN = function(f) gsub(pattern, "\\2", f))
  }
}


filter_files_info <- function(files, info = sysinfo()) {
  for (op in c("=", "!=")) {
    ## Parse <key>=<value> and keep only matching ones
    for (key in names(info)) {
      ## Identify files specifying this <key>=<value> or <key>!=<value>
      pattern <- sprintf(".*[^a-z]*(%s)%s([^=,/]*).*", key, op)
      idxs <- grep(pattern, files, fixed = FALSE)
      if (length(idxs) == 0) next

      ## There could be more than one <key>=<name> specification
      ## per pathname that use the same <key>, e.g. package=nnn.
      files_values <- list_of_values(files[idxs], pattern = pattern)

      ## sysinfo() keys
      value <- info[[key]]
      if (is.logical(value)) {
        files_values <- unlist(files_values, use.names = FALSE)
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

      if (length(drop) > 0) files <- files[-drop]
    } ## for (key ...)
  } ## for (op ...)

  files
} ## filter_files_info()


filter_files_package <- function(files) {
  for (op in c("=", "!=")) {
    ## Parse <key>=<value> and keep only matching ones

    ## Identify files specifying this <key>=<value> or <key>!=<value>
    pattern <- sprintf(".*[^a-z]*(package)%s([^=,/]*).*", op)
    idxs <- grep(pattern, files, fixed = FALSE)
    if (length(idxs) == 0) next

    ## There could be more than one <key>=<name> specification
    ## per pathname that use the same <key>, e.g. package=nnn.
    files_values <- list_of_values(files[idxs], pattern = pattern)

    files_ok <- lapply(files_values, FUN = function(values) {
      ## Check which packages are installed and can be loaded
      keep <- lapply(values, FUN = is_package_installed)
      keep <- unlist(keep, use.names = FALSE)
      if (op == "!=") keep <- !keep
      all(keep)
    })
    files_ok <- unlist(files_ok, use.names = FALSE)
    drop <- idxs[!files_ok]

    if (length(drop) > 0) files <- files[-drop]
  } ## for (op ...)

  files
} ## filter_files_package()


filter_files_when <- function(files) {
  already_done <- list(
    file = NULL,
    last_processed = NULL
  )
  
  for (op in c("=")) {
    ## Parse <key>=<value> and keep only matching ones

    ## Identify files specifying this <key>=<value>
    pattern <- sprintf(".*[^a-z]*(when)%s([^=,/]*).*", op)
    idxs <- grep(pattern, files, fixed = FALSE)
    if (length(idxs) == 0) next

    ## There could be more than one <key>=<name> specification
    ## per pathname that use the same <key>, e.g. package=nnn.
    files_values <- list_of_values(files[idxs], pattern = pattern)

    ## Keep unique 'when' conditions
    files_values <- lapply(files_values, FUN = unique)

    ## Drop unknown 'when' conditions
    files_values <- lapply(files_values, FUN = function(when) {
      intersect(when, agenda_known_whens)
    })

    ## Ignore multiple *different* or empty 'when' statements
    n <- unlist(lapply(files_values, FUN = length), use.names = FALSE)
    if (any(n != 1L)) {
      non_unique <- files[idxs][n > 1L]
      keep <- which(n == 1L)
      idxs <- idxs[keep]
      if (length(idxs) == 0) next
      files_values <- files_values[keep]
    }

    last_processed_op <- vector("list", length = length(idxs))
    done <- logical(length(idxs))
    for (kk in seq_along(idxs)) {
      file <- files[idxs[kk]]
      when <- files_values[[kk]]
      agenda_file <- get_agenda_file(file, when = when)
      done_kk <- is_agenda_file_done(agenda_file)
      done[kk] <- done_kk
      last_processed_op[kk] <- list(attr(done_kk, "last_processed"))
    }
    
    already_done[["file"]] <- c(already_done[["file"]], files[idxs][done])
    already_done[["last_processed"]] <- c(already_done[["last_processed"]], last_processed_op[done])
    
    drop <- idxs[done]

    if (length(drop) > 0) files <- files[-drop]
  } ## for (op ...)

  if (length(already_done[["file"]]) > 0L) {
    attr(files, "already_done") <- already_done
  }

  files
} ## filter_files_when()


filter_files_env <- function(files, ignore = c(names(sysinfo()), "package")) {
  envs <- Sys.getenv()

  unknown_keys <- NULL
  
  for (op in c("=", "!=")) {
    ## Identify files specifying this <key>=<value> or <key>!=<value>
    pattern <- sprintf("^([a-zA-Z_][a-zA-Z0-9_]*)%s([^=,/]*).*", op)
    files_values <- list_of_values(files, pattern = pattern, names = TRUE)

    ## Drop <key>=<value> elements that refers to sysinfo() or packages
    files_values <- lapply(files_values, FUN = function(x) {
      x[!names(x) %in% ignore]
    })

    idxs <- which(sapply(files_values, FUN = length) > 0)
    if (length(idxs) == 0) next

    ## There could be more than one <key>=<name> specification
    ## per pathname that use the same <key>, e.g. package=nnn.
    env_names <- names(envs)
    files_ok <- lapply(files_values[idxs], FUN = function(values) {
      keys <- names(values)
      
      ## Check for keys for which there exist *no* environment variable
      missing <- keys[is.na(match(keys, env_names))]
      if (length(missing) > 0) return(missing)
      
      truth <- envs[keys]
      keep <- (values == truth)
      if (op == "!=") keep <- !keep
      all(keep)
    })

    
    ## Any files with un-declared 'key' in their pathnames?
    has_unknown_keys <- which(unlist(lapply(files_ok, FUN = is.character)))
    if (length(has_unknown_keys) > 0) {
      unknown_keys_op <- files_ok[has_unknown_keys]
      names(unknown_keys_op) <- files[idxs[has_unknown_keys]]
      if (op == "==") {
        unknown_keys <- c(unknown_keys, unknown_keys_op)
        files_ok[has_unknown_keys] <- FALSE
      } else {
        files_ok[has_unknown_keys] <- TRUE
      }
    }

    files_ok <- unlist(files_ok, use.names = FALSE)
    drop <- idxs[!files_ok]

    if (length(drop) > 0) files <- files[-drop]
  } ## for (op ...)

  attr(files, "unknown_keys") <- unknown_keys
  
  files
} ## filter_files_env()


filter_files <- function(files, info = sysinfo()) {
  files <- filter_files_info(files, info = info)
  
  files <- filter_files_package(files)
  
  files <- filter_files_when(files)
  already_done <- attr(files, "already_done")
  
  files <- filter_files_env(files, ignore = c(names(info), "package", "when"))

  attr(files, "already_done") <- already_done

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
