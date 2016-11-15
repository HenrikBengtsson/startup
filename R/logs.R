log <- function(..., collapse="\n") {
  args <- commandArgs()
  if (is.element("--slave", args)) return()
  debug <- as.logical(Sys.getenv("R_STARTUP_DEBUG", "FALSE"))
  debug <- getOption("startup.debug", debug)
  if (!debug) return()
  message(paste(..., collapse = collapse))
}

logf <- function(..., collapse = "\n") {
  log(sprintf(...), collapse = collapse)
}

logp <- function(expr, ...) {
  log(utils::capture.output(print(expr)), ...)
}
