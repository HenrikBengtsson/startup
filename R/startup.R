#' Simplified Initialization at Start of an R Session
#'
#' Initiates R using all files under \file{.Renviron.d/}
#' and / or \file{.Rprofile.d/} directories
#' (or in subdirectories thereof).
#' Any \file{.Renviron.d/} and \file{.Rprofile.d/} directories
#' in user's home directory (`~`) are first processed followed
#' by any in the in the current directory (`.`).
#'
#' The above is done in addition the \file{.Renviron} and
#' \file{.Rprofile} files that re supported by the built-in
#' \link[base:Startup]{startup process} of \R.
#'
#' @param all If \code{TRUE}, then all \file{.Renviron.d/} and \file{.Rprofile.d/} directories found on the R startup search paths are processed, otherwise only the first ones found.
#' @param unload If \code{TRUE}, then the package is unloaded afterward, otherwise not.
#' @param debug If \code{TRUE}, debug messages are outputted, otherwise not.
#'
#' @examples
#' \dontrun{
#' # The most common way to use the package is to add
#' # the following call to the ~/.Rprofile file.
#' startup::startup()
#'
#' # For finer control of on exactly what files are used
#' # functions renviron() and rprofile() are also available:
#'
#' # Initiate any ./.Renviron.d/ and ~/.Renviron.d/ files
#' startup::renviron()
#'
#' # Initiate only the first .Rprofile.d/ directory of files
#' startup::rprofile(all = FALSE)
#'
#' # Initiate .Renviron.d/ files then .Rprofile.d/ files
#' startup::renviron()$rprofile()
#' }
#'
#' @describeIn startup \code{renviron()} followed by \code{rprofile()} and then the package is unloaded
#' @export
startup <- function(all = FALSE, unload = TRUE, debug = NA) {
  debug(debug)

  # (i) Load custom .Renviron.d/* files
  renviron(all = all)
  
  # (ii) Load custom .Rprofile.d/* files
  rprofile(all = all)

  res <- api()
  if (unload) unload()
  invisible(res)
}
