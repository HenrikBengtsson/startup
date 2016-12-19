#' @describeIn startup Initiate using \file{.Rprofile.d/} files
#' @aliases rprofile
#' @export
rprofile_d <- function(sibling = FALSE, all = FALSE, unload = FALSE, skip = NA, debug = NA, on_error = c("error", "warning", "immediate.warning", "message", "ignore")) {
  debug <- debug(debug)
  
  ## Skip?
  if (is.na(skip)) {
    skip <- any(c("--no-init-file", "--vanilla") %in% commandArgs())
  }

  # (i) Check and fix common errors
  check(all = all, fix = TRUE, debug = FALSE)
  debug(debug)

  if (!skip) {
    # (ii) Load custom .Rprofile.d/* files
    startup_apply("Rprofile", sibling = sibling, all = all, print.eval = TRUE, on_error = on_error)
  
    # (iii) Validate .Rprofile encoding
    check_rprofile_encoding()
  }
  
  res <- api()
  if (unload) unload()
  invisible(res)
}

#' @export
rprofile <- function(...) {
  .Deprecated(new = "startup::rprofile_d()")
  rprofile_d(...)
}

