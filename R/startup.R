#' Load .Renviron.d and .Rprofile.d directories during the R startup process
#'
#' Initiates \R using all files under \file{.Renviron.d/}
#' and / or \file{.Rprofile.d/} directories
#' (or in subdirectories thereof).
#'
#' The above is done in addition the \file{.Renviron} and
#' \file{.Rprofile} files that are supported by the built-in
#' \link[base:Startup]{startup process} of \R.
#'
#' @param sibling If \code{TRUE}, then only \file{.Renviron.d/} and \file{.Rprofile.d/} directories with a sibling \file{.Renviron} and \file{.Rprofile} in the same location will be considered.
#' @param all If \code{TRUE}, then \emph{all} \file{.Renviron.d/} and \file{.Rprofile.d/} directories found on \link[base:Startup]{the R startup search path} are processed, otherwise only the \emph{first ones} found.
#' @param on_error Action taken when an error is detected when sourcing an Rprofile file.  It is not possible to detect error in Renviron files; they are always ignored with a message that cannot be captured.
#' @param unload If \code{TRUE}, then the package is unloaded afterward, otherwise not.
#' @param skip If \code{TRUE}, startup directories will be skipped.  If \code{NA}, they will be skipped if command-line options \code{--vanilla}, \code{--no-init-file}, and / or \code{--no-environ} were specified.
#' @param debug If \code{TRUE}, debug messages are outputted, otherwise not.
#'
#' @section User-specific installation:
#' In order for \file{.Rprofile.d} and \file{.Renviron.d} directories
#' to be included during the \R startup process, a user needs to add
#' \code{startup::startup()} to \file{~/.Rprofile}.  Adding this can
#' also be done by calling \code{\link[startup:install]{startup::install()}} once.
#'
#' @section Site-wide installation:
#' An alternative to having each user add \code{startup::startup()} in
#' their own \file{~/.Rprofile} file, is to add it to the site-wide
#' \file{Rprofile.site} file (see \code{\link[base:Startup]{?Startup}}).
#' The advantage of such a site-wide installation, is that the users
#' do not have to have a \file{.Rprofile} file for \file{.Rprofile.d}
#' and \file{.Renviron.d} directories to work.
#' For this to work for all users automatically, the \pkg{startup} package
#' should also be installed in the site-wide library.
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
#' # Initiate first .Renviron.d/ found on search path
#' startup::renviron()
#'
#' # Initiate all .Rprofile.d/ directories found on the startup search path
#' startup::rprofile(all = TRUE)
#' }
#'
#' @describeIn startup \code{renviron()} followed by \code{rprofile()} and then the package is unloaded
#' @export
startup <- function(sibling = FALSE, all = FALSE, on_error = c("error", "warning", "immediate.warning", "message", "ignore"), unload = TRUE, skip = NA, debug = NA) {
  debug(debug)

  # (i) Load custom .Renviron.d/* files
  renviron(sibling = sibling, all = all, skip = skip)
  
  # (ii) Load custom .Rprofile.d/* files
  rprofile(sibling = sibling, all = all, skip = skip, on_error = on_error)

  res <- api()
  if (unload) unload()
  invisible(res)
}
