#' @describeIn startup Initiate using \file{.Renviron.d/} files
#' @export
renviron <- function(paths = c("~", "."), unload = FALSE, debug = NA) {
  debug(debug)
  
  args <- commandArgs()

  ## Skip?
  skip <- ("--no-environ" %in% args)

  if (!skip) {
    # Load custom .Renviron.d/* files
    startup_apply("Renviron")
  }
  
  res <- api()
  if (unload) unload()
  invisible(res)
}
