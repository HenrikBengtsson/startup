#' Simplified Initialization at Start of an R Session
#'
#' Initiates R using all files under \file{.Renviron.d/}
#' and / or \file{.Rprofile.d/} directories (or in subdirectories)
#' thereof.  This is done in addition the \file{.Renviron} and
#' \file{.Rprofile} files supported by the
#' \link[base:Startup]{default R startup process}.
#' Directories \file{.Renviron.d/} and \file{.Rprofile.d/} may
#' be located in the current directory and / or the user's home
#' directory.
#'
#' @param paths Character vector of paths where to locate the \file{.Renviron.d/} and \file{.Rprofile.d/} directories.
#' @param unload If \code{TRUE}, then the package is unloaded afterward, otherwise not.
#' @param debug If \code{TRUE}, debug messages are outputted, otherwise not.
#'
#' @examples
#' \dontrun{
#' # The most common way to use the package
#' startup::startup()
#'
#' # Initiate any ./.Renviron.d/ and ~/.Renviron.d/ files
#' startup::renviron()
#'
#' # Initiate only ~/.Rprofile.d/ files
#' startup::rprofile(paths = "~")
#'
#' # Initiate .Renviron.d/ files then .Rprofile.d/ files
#' startup::renviron()$rprofile()
#' }
#'
#' @describeIn startup \code{renviron()} followed by \code{rprofile()} and then the package is unloaded
#' @export
startup <- function(paths = c(".", "~"), unload = TRUE, debug = NA) {
  debug(debug)
  # (i) Load custom .Renviron.d/* files
  renviron(paths = paths)
  # (ii) Load custom .Rprofile.d/* files
  rprofile(paths = paths)

  res <- api()
  if (unload) unload()
  invisible(res)
}

#' @describeIn startup Initiate using \file{.Renviron.d/} files
#' @export
renviron <- function(paths = c(".", "~"), unload = FALSE, debug = NA) {
  debug(debug)
  # Load custom .Renviron.d/* files
  startup_apply(".Renviron.d", FUN = readRenviron, paths = paths)
  res <- api()
  if (unload) unload()
  invisible(res)
}

#' @describeIn startup Initiate using \file{.Rprofile.d/} files
#' @export
rprofile <- function(paths = c(".", "~"), unload = FALSE, debug = NA) {
  debug(debug)
  # (a) Load custom .Rprofile.d/* files
  startup_apply(".Rprofile.d", FUN = source, paths = paths)
  # (b) Validate .Rprofile
  check_rprofile()
  res <- api()
  if (unload) unload()
  invisible(res)
}
