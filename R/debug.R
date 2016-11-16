debug <- local({
  status <- NA
  
  function(action = NA) {
    if (is.na(status)) {
      args <- commandArgs()
      t <- as.logical(Sys.getenv("R_STARTUP_DEBUG", "FALSE"))
      t <- getOption("startup.debug", t)
      t <- isTRUE(t)
      if (any(c("-q", "--quiet", "--silent", "--slave") %in% args)) t <- FALSE
      if ("--verbose" %in% args) t <- TRUE
      status <<- t
    }
    
    action <- as.logical(action)
    if (!is.na(action)) status <<- action
    status
  }
})

log <- function(..., collapse = "\n") {
  if (!debug()) return()
  message(paste(..., collapse = collapse))
}

logf <- function(..., collapse = "\n") {
  log(sprintf(...), collapse = collapse)
}

logp <- function(expr, ...) {
  log(utils::capture.output(print(expr)), ...)
}
