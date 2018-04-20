#' Organize Your Toolbox
#' 
#' @param expr An \R expression to be evaluated inside the 'mytoolbox'
#' environment.  The default is to list all tools in the toolbox.
#'
#' @param name (optional) The name of the toolbox environment.
#' 
#' @details
#' Your tools will be kept first on the [search][base::search] path.
#' For instance, if one of your tools have the same name as a function in
#' an _attached_ package, your tool will be used.
#' This is achieved by always moving the 'mytoolbox' environment (where your
#' tools sits) to the front of the [search][base::search] path whenever the
#' `startup::mytoolbox()` function is called.
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
#' ## List all tools in the toolbox (and move toolbox to the front)
#' startup::mytoolbox()
#' 
#' @export
mytoolbox <- function(expr = ls(all.names = TRUE), name = "startup::mytoolbox") {
  expr <- substitute(expr)
  envir <- mytoolboxenv(name = name)
  res <- withVisible(eval(expr, envir = envir))

  ## Move 'mytoolbox' to the front of the search path
  mytoolboxenv(pos = 2L)

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
