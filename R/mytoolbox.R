#' Organize Your Toolbox
#' 
#' @param expr An \R expression to be evaluated inside the 'mytoolbox'
#' environment.  The default is to list all tools in the toolbox.
#'
#' @param name (optional) The name of the toolbox environment.
#' 
#' @param pos (optional) A numeric. If specified, the toolbox will be moved
#' to this location on the search path.
#' 
#' @details
#' One or more of your tools in your toolbox may be masked by functions in
#' _attached_ packages.  To avoid this, move your toolbox to the front of
#' the [search][base::search] path by calling `startup::mytoolbox(pos = 2L)`.
#'
#' An empty toolbox environment is removed automatically.  To empty one, use
#' `startup::mytoolbox(rm(list = ls(all.names = TRUE)))`.
#' 
#' @examples
#' ## Add tools to the toolbox
#' startup::mytoolbox({
#'   ## Quit R without questions
#'   Q <- function(save = "no", ...) quit(save = save, ...)
#'
#'   ## List _all_ variables
#'   ll <- startup::partial(ls, all.names = TRUE)
#' })
#'
#' ## Add another tool to the toolbox
#' startup::mytoolbox({
#'   ## Install package in current directory from source
#'   install <- startup::partial(utils::install.packages,
#'                               pkgs = ".", repos = NULL)
#' })
#'
#' ## List all tools in the toolbox
#' startup::mytoolbox()
#'
#' \dontrun{
#' ## Remove toolbox by emptying it
#' startup::mytoolbox(rm(list = ls(all.names = TRUE)))
#' }
#' 
#' @export
mytoolbox <- function(expr = ls(all.names = TRUE), name = "startup::mytoolbox", pos = NULL) {
  expr <- substitute(expr)
  envir <- mytoolboxenv(name = name)
  res <- withVisible(eval(expr, envir = envir))

  ## Move the toolbox on the search path?
  if (is.numeric(pos)) mytoolboxenv(pos = pos, name = name)

  ## Remove toolbox iff it's empty
  if (length(ls(envir = envir, all.names = TRUE, sorted = FALSE)) == 0L)
    mytoolboxenv(remove = TRUE, name = name)
  
  if (res$visible) res$value else invisible(res$value)
}


mytoolboxenv <- function(pos = NULL, remove = FALSE, name = "startup::mytoolbox") {
  attach_toolbox <- function(what = NULL, pos = 2L) {
    ## Avoid false-positive NOTE from R CMD check
    do.call(attach, args = list(what = what, name = name, pos = pos))
  }
  idx <- match(name, search())
  env <- if (is.na(idx)) NULL else as.environment(name)
  if (remove) {
    if (!is.null(env)) detach(name = name, character.only = TRUE)
    return(NULL)
  } else if (is.numeric(pos)) {
    if (!is.null(env)) detach(name = name, character.only = TRUE)
    attach_toolbox(env, pos = pos)
  } else {
    if (is.null(env)) attach_toolbox()
  }
  as.environment(name)
}
