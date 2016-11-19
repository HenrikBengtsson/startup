#' @describeIn startup Initiate using \file{.Renviron.d/} files
#' @export
renviron <- function(all = FALSE, unload = FALSE, skip = NA, debug = NA) {
  debug(debug)
  
  ## Skip?
  if (is.na(skip)) {
    skip <- any(c("--no-environ", "--vanilla") %in% commandArgs())
  }

  if (!skip) {
    # Load custom .Renviron.d/* files
    startup_apply("Renviron", all = all)
  }
  
  res <- api()
  if (unload) unload()
  invisible(res)
}
