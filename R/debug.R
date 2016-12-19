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
        if (any(c("-q", "--quiet", "--silent", "--slave") %in% args)) t <- FALSE
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
}

logf <- function(..., collapse = "\n") {
  log(sprintf(...), collapse = collapse)
}

logp <- function(expr, ...) {
  log(utils::capture.output(print(expr)), ...)
}

timestamp <- local({
  t0 <- NULL
  function() {
    if (is.null(t0)) {
      t0 <<- Sys.time()
    }
    dt <-  difftime(Sys.time(), t0, units = "secs")
    sprintf("%4.2fs", as.numeric(dt))
  }
})

