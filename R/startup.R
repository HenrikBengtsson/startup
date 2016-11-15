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
#' @param debug If \code{TRUE}, debug messages are outputted, otherwise not.
#'
#' @examples
#' \dontrun{
#' # Initiate any ./.Renviron.d/ and ~/.Renviron.d/ files
#' startup::renviron()
#'
#' # Initiate only ~/.Rprofile.d/ files
#' startup::rprofile(paths = "~/.Rprofile.d/")
#'
#' # Initiate .Renviron.d/ files then .Rprofile.d/ files
#' startup::renviron()$rprofile()
#'
#' # Initiate everything (as above in the same order)
#' startup::everything()
#'   
#' # Initiate everything and unload package afterward
#' startup::everything()$unload()
#' }
#'
#' @rdname startup
#' @name startup
NULL

#' @describeIn startup \code{renviron()} followed by \code{rprofile()}
#' @export
everything <- function(paths = c(".", "~"), debug = NA) {
  debug(debug)
  # (i) Load custom .Renviron.d/* files
  renviron(paths = paths)
  # (ii) Load custom .Rprofile.d/* files
  rprofile(paths = paths)  
  invisible(api())
}

#' @describeIn startup Initiate using \file{.Renviron.d/} files
#' @export
renviron <- function(paths = c(".", "~"), debug = NA) {
  debug(debug)
  # Load custom .Renviron.d/* files
  startup_apply(".Renviron.d", FUN = readRenviron, paths = paths)
  invisible(api())
}

#' @describeIn startup Initiate using \file{.Rprofile.d/} files
#' @export
rprofile <- function(paths = c(".", "~"), debug = NA) {
  debug(debug)
  # (a) Load custom .Rprofile.d/* files
  startup_apply(".Rprofile.d", FUN = source, paths = paths)
  # (b) Validate .Rprofile
  check_rprofile()
  invisible(api())
}
