#' Record R session information as options
#'
#' @param action If `"update"` or `"overwrite"`, \R options
#' `"startup.session.*"` are set.  If `"update"`, then such options
#' that are not already set are updated.
#' If `"erase"`, any existing `"startup.session.*"` options are
#' removed.
#' 
#' @return Returns invisibly a named list of the options prefixed
#' `"startup.session."`:
#' \describe{
#'   \item{`startup.session.startdir`}{(character) the directory where
#'     the \R session was launched from}
#'   \item{`startup.session.id`}{(character) a unique ID for the current
#'     \R session}
#'   \item{`startup.session.dumpto`}{(character) a value that can be used
#'     for argument `dumpto` of [dump.frames()][utils::dump.frames]
#'     (also for dumping to file)}
#' }
#'
#' @examples
#' opts <- startup::startup_session_options()
#' opts
#'
#' @export
startup_session_options <- function(action = c("update", "overwrite", "erase")) {
  action <- match.arg(action)

  if (action %in% c("update", "overwrite")) {  
    pwd <- getwd()
    id <- basename(tempdir())
  
    opts <- list(
      startup.session.startdir = pwd,
      startup.session.id = id,
      startup.session.dumpto = file.path(pwd, sprintf("last.dump_%s", id))
    )
  
    ## Reuse existing startup.session.* options?
    if (action == "update") {
      old_opts <- options()
      old_opts <- old_opts[grep("^startup[.]session[.]", names(old_opts))]    
      for (name in names(old_opts)) opts[[name]] <- old_opts[[name]]
    }
    
    do.call(options, args = opts)
  } else if (action == "erase") {
    opts <- options()
    opts <- opts[grep("^startup[.]session[.]", names(opts))]
    for (name in names(opts)) opts[name] <- NULL
    do.call(options, args = opts)
  }

  invisible(opts)
}
