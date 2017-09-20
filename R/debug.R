debug <- local({
  status <- NA

  function(action = NA) {
    if (is.na(status)) {
      t <- as.logical(Sys.getenv("R_STARTUP_DEBUG", NA))
      t <- getOption("startup.debug", t)

      ## If neither env var nor option is specified, then
      ## look at command-line options
      if (is.na(t)) {
        args <- commandArgs()
        if (any(c("-q", "--quiet", "--silent", "--slave") %in% args)) {
          t <- FALSE
        }
        if ("--verbose" %in% args) t <- TRUE
      }

      t <- isTRUE(t)

      status <<- t
    }

    action <- as.logical(action)
    if (!is.na(action)) status <<- action
    status
  }
})

log <- function(..., collapse = "\n") {
  if (!debug()) return()
  lines <- c(...)
  lines <- sprintf("%s: %s", timestamp(), lines)
  message(paste(lines, collapse = collapse))
  invisible()
}

logf <- function(..., collapse = "\n") {
  log(sprintf(...), collapse = collapse)
}

logp <- function(expr, ...) {
  log(utils::capture.output(print(expr)), ...)
}

timestamp <- local({
  t0 <- NULL
  function(get_t0 = FALSE) {
    if (get_t0) return(t0)
    if (is.null(t0)) {
      t0 <<- Sys.time()
    }
    dt <-  difftime(Sys.time(), t0, units = "secs")
    sprintf("%5.3fs", as.numeric(dt))
  }
})

notef <- function(..., quiet = FALSE) {
  if (!quiet) message(sprintf(...))
}

is_file <- function(f) nzchar(f) && file.exists(f) && !file.info(f)$isdir

nlines <- function(f) {
  bfr <- readLines(f, warn = FALSE)
  bfr <- grep("^[ \t]*#", bfr, value = TRUE, invert = TRUE)
  bfr <- grep("^[ \t]*$", bfr, value = TRUE, invert = TRUE)
  length(bfr)
}

file_info <- function(f, type = "txt", normalize = FALSE) {
  if (normalize) f <- normalizePath(f, mustWork = FALSE)
  if (type == "binary") {
    sprintf("%s (binary file; %d bytes)", sQuote(f), file.size(f))
  } else if (type == "env") {
    sprintf("%s (%d lines; %d bytes)",
            sQuote(f), nlines(f), file.size(f))
  } else if (type == "r") {
    sprintf("%s (%d code lines; %d bytes)",
            sQuote(f), nlines(f), file.size(f))
  } else {
    sprintf("%s (%d lines; %d bytes)",
            sQuote(f), nlines(f), file.size(f))
  }
}
