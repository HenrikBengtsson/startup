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
#' @param paths Character vector of paths where to locate the \file{.Renviron.d/} and \file{.Rprofile.d/} directories.
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
#' # Initiate only ~/.Rprofile.d/ files
#' startup::rprofile(paths = "~")
#'
#' # Initiate .Renviron.d/ files then .Rprofile.d/ files
#' startup::renviron()$rprofile()
#' }
#'
#' @describeIn startup \code{renviron()} followed by \code{rprofile()} and then the package is unloaded
#' @export
startup <- function(paths = c("~", "."), unload = TRUE, debug = NA) {
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
renviron <- function(paths = c("~", "."), unload = FALSE, debug = NA) {
  debug(debug)
  
  args <- commandArgs()

  ## Skip?
  skip <- ("--no-environ" %in% args)

  if (!skip) {
    # Load custom .Renviron.d/* files
    startup_apply(".Renviron.d", FUN = readRenviron, paths = paths)
  }
  
  res <- api()
  if (unload) unload()
  invisible(res)
}

#' @describeIn startup Initiate using \file{.Rprofile.d/} files
#' @export
rprofile <- function(paths = c("~", "."), unload = FALSE, debug = NA) {
  debug(debug)
  
  # (i) Check and fix common errors
  check(paths = paths, fix = TRUE)
  
  # (ii) Load custom .Rprofile.d/* files
  startup_apply(".Rprofile.d", FUN = source, paths = paths)
  
  # (iii) Validate .Rprofile encoding
  check_rprofile_encoding()
  
  res <- api()
  if (unload) unload()
  invisible(res)
}
