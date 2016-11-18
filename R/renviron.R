#' @describeIn startup Initiate using \file{.Renviron.d/} files
#' @export
renviron <- function(all = FALSE, unload = FALSE, debug = NA) {
  debug(debug)
  
  args <- commandArgs()

  ## Skip?
  skip <- ("--no-environ" %in% args)

  if (!skip) {
    # Load custom .Renviron.d/* files
    startup_apply("Renviron", all = all)
  }
  
  res <- api()
  if (unload) unload()
  invisible(res)
}
