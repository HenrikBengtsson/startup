#' Organize Your Toolbox
#' 
#' @param expr An \R expression to be evaluated inside the 'mytoolbox'
#' environment.  The default is to list all tools in the toolbox.
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
#' @export
mytoolbox <- function(expr = ls(all.names = TRUE)) {
  expr <- substitute(eval(
    quote(expr),
    envir = get("mytoolboxenv", envir = getNamespace("startup"))()
  ))
  eval.parent(expr, n = 1L)
}


mytoolboxenv <- function(pos = NULL, remove = FALSE) {
  attach_toolbox <- function(what = NULL, pos = 2L) {
    ## Avoid false-positive NOTE from R CMD check
    do.call(attach, args = list(what = what, name = "mytoolbox", pos = pos))
  }
  idx <- match("mytoolbox", search())
  env <- if (is.na(idx)) NULL else as.environment("mytoolbox")
  if (remove) {
    if (!is.null(env)) detach(name = "mytoolbox")
    return(NULL)
  } else if (is.numeric(pos)) {
    if (!is.null(env)) detach(name = "mytoolbox")
    attach_toolbox(env, pos = pos)
  } else {
    if (is.null(env)) attach_toolbox()
  }
  as.environment("mytoolbox")
}
