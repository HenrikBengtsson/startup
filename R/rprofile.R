#' @describeIn startup Initiate using \file{.Rprofile.d/} files
#' @export
rprofile <- function(paths = c("~", "."), unload = FALSE, debug = NA) {
  debug(debug)

  args <- commandArgs()

  ## Skip?
  skip <- ("--no-init-file" %in% args)

  # (i) Check and fix common errors
  check(paths = paths, fix = TRUE)
  
  if (!skip) {
    # (ii) Load custom .Rprofile.d/* files
    startup_apply("Rprofile")
  
    # (iii) Validate .Rprofile encoding
    check_rprofile_encoding()
  }
  
  res <- api()
  if (unload) unload()
  invisible(res)
}
