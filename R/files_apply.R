files_apply <- function(files, fun,
                        on_error = c("error", "warning", "immediate.warning",
                                     "message", "ignore"),
                        dryrun = NA,
                        what = c("Renviron", "Rprofile"),
                        debug = NA) {
  stop_if_not(is.function(fun))
  on_error <- match.arg(on_error)
  what <- match.arg(what)
  debug <- debug(debug)
  
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
                       squote(pathname), msg)
        if (on_error == "error") {
          stop("startup::files_apply(): ", msg, call. = FALSE)
        } else if (on_error == "warning") {
          warning("startup::files_apply(): ", msg, call. = FALSE)
        } else if (on_error == "immediate.warning") {
          warning("startup::files_apply(): ", msg, immediate. = TRUE, call. = FALSE)
        } else if (on_error == "message") {
          message("startup::files_apply(): ", msg)
        }
      }
      res
    }
  }

  logf("Processing %d %s files ...", length(files), what)
  if (what == "Renviron") {
    type <- "env"
  } else if (what == "Rprofile") {
    type <- "r"
    if (debug) {
      ## (a) Loaded and attached packages
      record_pkgs <- function() {
        res <- list()
        res$loaded <- loadedNamespaces()
        res$attached <- sort(search())
        res$attached_envs <- grep("^package:", res$attached, invert = TRUE, value = TRUE)
        res$attached <- gsub("^package:", "", grep("^package:", res$attached, value = TRUE))
        res
      }

      ## (b) Environment variables
      record_envvars <- function() {
        Sys.getenv()
      }

      ## (c) R options
      record_options <- function() {
        options()
      }

      ## (d) Global variables
      record_globals <- function() {
        as.list(globalenv())
      }

      ## (e) Random number generator (RNG) state
      record_rng <- function() {
        globalenv()$.Random.seed
      }
    }
  }

  for (file in files) {
    ## Get 'when=<periodicity>' declaration, if it exists
    when <- get_when(file)
    logf(" - %s", file_info(file, type = type, extra = sprintf("when=%s", when)))

    if (debug && what == "Rprofile") {
      before <- list(
        envvars = record_envvars(),
        globals = record_globals(),
        options = record_options(),
           pkgs = record_pkgs(),
            rng = record_rng()
      )
    }

    call_fun(file)

    if (debug && what == "Rprofile") {
      after <- list(
        envvars = record_envvars(),
        globals = record_globals(),
        options = record_options(),
           pkgs = record_pkgs(),
            rng = record_rng()
      )

      ## (a) Packages
      ## Identified added entries
      added <- mapply(after$pkgs, before$pkgs, FUN = setdiff)
      added$loaded <- setdiff(added$loaded, added$attached)
      
      ## Identified removed entries
      removed <- mapply(before$pkgs, after$pkgs, FUN = setdiff)
      removed$attached <- setdiff(removed$attached, removed$loaded)
      names(removed) <- gsub("attached", "detached", names(removed))
      names(removed) <- gsub("loaded", "unloaded", names(removed))
      
      nadded <- sapply(added, FUN = length)
      nremoved <- sapply(removed, FUN = length)

      s <- NULL
      for (kind in c("attached", "loaded")) {
        if (nadded[[kind]] > 0) {
          s <- c(s, sprintf("%s %s (%s)",   nadded[[kind]], kind, paste(sQuote(  added[[kind]]), collapse = ", ")))
        }
      }
      for (kind in c("detached", "unloaded")) {
        if (nremoved[[kind]] > 0) {
          s <- c(s, sprintf("%s %s (%s)", nremoved[[kind]], kind, paste(sQuote(removed[[kind]]), collapse = ", ")))
        }
      }
      if (length(s) > 0) {
        s <- paste(s, collapse = ", ")
        logf("           Packages: %s", s, timestamp = FALSE)
      }
      
      ## Search path
      s <- NULL
      kind <- "attached_envs"
      if (nadded[kind] > 0) {
        s <- c(s, sprintf("%s environment attached (%s)",   nadded[[kind]],  paste(sQuote(  added[[kind]]), collapse = ", ")))
      }
      kind <- "detached_envs"
      if (nremoved[kind] > 0) {
        s <- c(s, sprintf("%s environment detached (%s)", nremoved[[kind]], paste(sQuote(  removed[[kind]]), collapse = ", ")))
      }
      if (length(s) > 0) {
        s <- paste(s, collapse = ", ")
        logf("           Search path: %s", s, timestamp = FALSE)
      }

      ## (b) Environment variables
      s <- NULL
      set <- setdiff(names(after$envvars), names(before$envvars))
      if (length(set) > 0) {
        s <- c(s, sprintf("%s added (%s)",   length(set), paste(sQuote(set), collapse = ", ")))
      }
      set <- setdiff(names(before$envvars), names(after$envvars))
      if (length(set) > 0) {
        s <- c(s, sprintf("%s removed (%s)", length(set), paste(sQuote(set), collapse = ", ")))
      }
      common <- intersect(names(before$envvars), names(after$envvars))
      diff <- which(before$envvars[common] != after$envvars[common])
      set <- names(diff)
      if (length(set) > 0) {
        s <- c(s, sprintf("%s changed (%s)", length(set), paste(sQuote(set), collapse = ", ")))
      }
      if (length(s) > 0) {
        s <- paste(s, collapse = ", ")
        logf("           Environment variables: %s", s, timestamp = FALSE)
      }

      ## (c) R options
      s <- NULL
      set <- setdiff(names(after$options), names(before$options))
      if (length(set) > 0) {
        s <- c(s, sprintf("%s added (%s)",   length(set), paste(sQuote(set), collapse = ", ")))
      }
      set <- setdiff(names(before$options), names(after$options))
      if (length(set) > 0) {
        s <- c(s, sprintf("%s removed (%s)", length(set), paste(sQuote(set), collapse = ", ")))
      }
      common <- intersect(names(before$options), names(after$options))
      same <- mapply(before$options[common], after$options[common], FUN = identical)
      set <- names(same)[!same]
      if (length(set) > 0) {
        s <- c(s, sprintf("%s changed (%s)", length(set), paste(sQuote(set), collapse = ", ")))
      }
      if (length(s) > 0) {
        s <- paste(s, collapse = ", ")
        logf("           R options: %s", s, timestamp = FALSE)
      }

      ## (d) Global variables
      s <- NULL
      set <- setdiff(names(after$globals), names(before$globals))
      if (length(set) > 0) {
        s <- c(s, sprintf("%s added (%s)",   length(set), paste(sQuote(set), collapse = ", ")))
      }
      set <- setdiff(names(before$globals), names(after$globals))
      if (length(set) > 0) {
        s <- c(s, sprintf("%s removed (%s)", length(set), paste(sQuote(set), collapse = ", ")))
      }
      common <- intersect(names(before$globals), names(after$globals))
      same <- mapply(before$globals[common], after$globals[common], FUN = identical)
      set <- names(same)[!same]
      if (length(set) > 0) {
        s <- c(s, sprintf("%s changed (%s)", length(set), paste(sQuote(set), collapse = ", ")))
      }
      if (length(s) > 0) {
        s <- paste(s, collapse = ", ")
        logf("           Global variables: %s", s, timestamp = FALSE)
      }
      
      ## (e) Random number generator (RNG) state
      rng_updated <- !identical(after$rng, before$rng)
      if (rng_updated) logf("           .Random.seed: updated", timestamp = FALSE)

      ## Not needed anymore
      before <- after <- NULL
    }

    if (length(when) == 1L) {
      when_cache_file <- get_when_cache_file(file, when = when)
      mark_when_file_done(when_cache_file)
    }
  }

  already_done <- attr(files, "already_done", exact = TRUE)
  n_done <- length(already_done[["file"]])
  if (n_done > 0L) {
    logf(" Skipped %d files with fulfilled 'when' statements:", n_done)
    last <- vapply(already_done[["last_processed"]], FUN = format, format = "%Y-%m-%d %H:%M:%S", FUN.VALUE = NA_character_)
    logf(sprintf(" - [SKIPPED] %s (processed on %s)", squote(already_done[["file"]]), last))
  }

  unknown_keys <- attr(files, "unknown_keys", exact = TRUE)
  if (length(unknown_keys) > 0) {
    unknown_files <- names(unknown_keys)
##    for (file in unknown_files) {
##      keys <- unknown_keys[[file]]
##      reason <- sprintf("non-declared keys: %s",
##                        paste(squote(keys), collapse = ", "))
##      logf(" - [SKIPPED] %s", file_info(file, type = type, extra = reason))
##    }
    unknown_keys <- sort(unique(unlist(unknown_keys)))
    logf("[WARNING] skipped %d files with non-declared key names (%s)", length(unknown_files), paste(squote(unknown_keys), collapse = ", "))
  }
  
  logf("Processing %d %s files ... done", length(files), what)
  if (dryrun) log("(all files were skipped because startup.dryrun = TRUE)")

  invisible(files)
}
