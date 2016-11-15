debug <- local({
  status <- NA
  
  function(action = NA) {
    if (is.na(status)) {
      t <- as.logical(Sys.getenv("R_STARTUP_DEBUG", "FALSE"))
      t <- getOption("startup.debug", t)
      status <<- isTRUE(t)
    }
    
    action <- as.logical(action)
    if (!is.na(action)) status <<- action
    status
  }
})

log <- function(..., collapse = "\n") {
  if (!debug()) return()
  if (is.element("--slave", commandArgs())) return()
  message(paste(..., collapse = collapse))
}

logf <- function(..., collapse = "\n") {
  log(sprintf(...), collapse = collapse)
}

logp <- function(expr, ...) {
  log(utils::capture.output(print(expr)), ...)
}
