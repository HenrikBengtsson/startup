#' Checks whether startup debug is on or not
#'
#' @return Returns `TRUE` is debug is enabled and `FALSE` otherwise.
#'
#' @details
#' The debug mode is when [startup::startup()] is called, either explicitly
#' via argument `debug` or via environment variable `R_STARTUP_DEBUG`.
#' 
#' @keywords internal
#' @export
is_debug_on <- function() debug()

debug <- local({
  status <- NA

  function(new = NA) {
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

    new <- as.logical(new)
    if (!is.na(new)) status <<- new
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
