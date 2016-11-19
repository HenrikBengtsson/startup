#' @describeIn startup Initiate using \file{.Rprofile.d/} files
#' @export
rprofile <- function(all = FALSE, unload = FALSE, debug = NA) {
  debug <- debug(debug)
  
  args <- commandArgs()

  ## Skip?
  skip <- ("--no-init-file" %in% args)

  # (i) Check and fix common errors
  check(all = all, fix = TRUE, debug = FALSE)
  debug(debug)

  if (!skip) {
    # (ii) Load custom .Rprofile.d/* files
    startup_apply("Rprofile", all = all)
  
    # (iii) Validate .Rprofile encoding
    check_rprofile_encoding()
  }
  
  res <- api()
  if (unload) unload()
  invisible(res)
}
