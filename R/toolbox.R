#' Organize Your Own Toolbox
#' 
#' @param expr An \R expression to be evaluated inside an 'toolbox'
#' environment.
#'
#' @param name (optional) The name of the toolbox environment.
#' 
#' @param pos (optional) A numeric. If specified, the toolbox will be moved
#' to this location on the search path.
#'
#' @return The value of the evaluated expression.  If `expr` is `NULL`
#' (default), then a named list of the content of all toolboxes.
#' 
#' @details
#' One or more of your tools in your toolbox may be masked by functions in
#' _attached_ packages.  To avoid this, move your toolbox to the front of
#' the [search][base::search] path by calling `startup::toolbox(pos = 2L)`.
#'
#' An empty toolbox environment is removed automatically.
#' To remove a toolbox, either empty it or move it to position zero or less.
#' 
#' @examples
#' ## Add tools to the toolbox
#' startup::toolbox({
#'   ## Quit R without questions
#'   Q <- function(save = "no", ...) quit(save = save, ...)
#'
#'   ## List _all_ variables
#'   ll <- startup::partial(ls, all.names = TRUE)
#' })
#'
#' ## Add another tool to the toolbox
#' startup::toolbox({
#'   ## Install package in current directory from source
#'   install <- startup::partial(utils::install.packages,
#'                               pkgs = ".", repos = NULL)
#' })
#'
#' ## List all tools in all toolboxes
#' startup::toolbox()
#'
#' \dontrun{
#' ## Remove toolbox by moving it to position zero
#' startup::toolbox(pos = 0)
#' }
#' 
#' @export
toolbox <- function(expr = NULL, name = "default", pos = NULL) {
  expr <- substitute(expr)

  envir <- toolboxenv(name = name)
  res <- withVisible(eval(expr, envir = envir))

  ## Get current set of tools
  objs <- ls(envir = envir, all.names = TRUE, sorted = FALSE)

  if (is.numeric(pos)) {
    if (pos <= 0)
      objs <- NULL
    else
      toolboxenv(pos = pos, name = name)
  }
  
  ## Remove toolbox? (iff it's empty)
  if (length(objs) == 0L) toolboxenv(remove = TRUE, name = name)

  if (!is.null(expr))
    if (res$visible) return(res$value) else return(invisible(res$value))
  
  ## Get content of all toolboxes?
  names <- grep("^toolbox:", search(), value = TRUE)
  res <- lapply(names, FUN = ls, all.names = TRUE, sorted = TRUE)
  names(res) <- sub("^toolbox:", "", names)
  
  res
}


toolboxenv <- function(pos = NULL, remove = FALSE, name = "default") {
  attach_toolbox <- function(what = NULL, pos = 2L) {
    ## Avoid false-positive NOTE from R CMD check
    do.call(attach, args = list(what = what, name = name, pos = pos))
  }
  name <- paste0("toolbox:", name)
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
