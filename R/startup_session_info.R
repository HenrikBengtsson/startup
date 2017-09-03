#' Record R session information as options
#'
#' @param reuse If \code{TRUE} and any of the \code{"startup.session.*"}
#' options are already recorded, then those are used, otherwise their values
#' are inferred from the information currently available.
#' 
#' @param record If \code{TRUE}, the information gathered is recorded as \R
#' options with prefix \code{"startup.session."} accessible as regular options,
#' e.g. \code{getOption("startup.session.startupdir")}.
#' 
#' @return Returns invisibly a named list of the options prefixed
#' \code{"startup.session."} including:
#' \describe{
#'   \item{\code{startup.session.startdir}}{(character) the directory where
#'     the \R session was launched from}
#'   \item{\code{startup.session.id}}{(character) a unique ID for the current
#'     \R session}
#'   \item{\code{startup.session.dumpto}}{(character) a value that can be used
#'     for argument \code{dumpto} of
#'     \code{\link[utils:dump.frames]{dump.frames()}}}
#'     (also for dumping to file)
#' }
#'
#' @examples
#' info <- startup::startup_session_info()
#' info
#'
#' @export
startup_session_info <- function(reuse = TRUE, record = TRUE) {
  pwd <- getwd()
  id <- basename(tempdir())

  info <- list(
    startup.session.startdir = pwd,
    startup.session.id = id,
    startup.session.dumpto = file.path(pwd, sprintf("last.dump_%s", id))
  )


  ## Reuse existing startup.session.* options? (only if skip = TRUE)
  if (reuse) {
    opts <- options()
    opts <- opts[grep("^startup[.]session[.]", names(opts))]
    for (name in names(opts)) info[[name]] <- opts[[name]]
  }

  ## Store as options?
  if (record) do.call(options, args = info)
  
  invisible(info)
}
