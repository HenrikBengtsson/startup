#' Register an R expression to be evaluated at the end of the R startup process
#' 
#' @param expr,substitute An R expression. If `substitute = TRUE`, `expr`
#' is automatically substituted.
#'
#' @param append If TRUE (default), the expression is added to the end of the
#' list of expression to be evaluated, otherwise prepended.
#'
#' @param replace if TRUE, the expression replaces all existing expressions
#' previously added, otherwise it will be added (default).
#'
#' @return (invisible) the list of registered expressions.
#'
#' @details
#' This function registers one or more R expressions to be evaluated at the
#' very end of the R startup process.  All expressions are evaluated in a
#' local environment.  The expressions are evaluated without exception
#' handlers, which means that if one expression produces an error, then
#' none of the following expression will be evaluated.
#'
#' The function works by recording all expressions `expr` in an internal list
#' which will be evaluated via a custom `.First()` function created in the
#' global environment. Any other `.First()` function on the search path,
#' including a pre-existing `.First()` function in the global environment,
#' is called at the end after registered expressions have been called.
#'
#' @export
on_session_start <- function(expr, substitute = TRUE, append = TRUE, replace = FALSE) {
    if (substitute) expr <- substitute(expr)
    stopifnot(is.logical(append), length(append) == 1L, !is.na(append))
    stopifnot(is.logical(replace), length(replace) == 1L, !is.na(replace))
    
    envir <- globalenv()
  
    ## Make sure to record any pre-existing .First() in the global environment
    first <- NULL
    tasks <- NULL
    if (exists(".First", envir = envir, inherits = FALSE)) {
      first <- get(".First", envir = envir, inherits = FALSE)
      env <- environment(first)
      if (isTRUE(env[["on_session_startup"]])) {
        first <- env[["preexisting"]]
        tasks <- env[["tasks"]]
      }
    }

    ## Replace?
    if (replace) tasks <- list()
  
    ## Append or prepend?
    task <- list(expr)
    tasks <- if (append) c(tasks, task) else c(task, tasks)

    preexisting <- NULL ## To please R CMD check
    
    .First <- function() {
      "This function was added by startup::on_session_start()"
      "Evaluate registered expressions, cf. environment(.First)$tasks"
      for (task in tasks) local(eval(task, envir = parent.frame()))
      
      ## Call any pre-existing .First() on the search path
      "Call any pre-existing .First() on the search path, including"
      "any pre-existing .First() function, cf. environment(.First)$tasks"
      .First <- preexisting
      
      ## Is there a .First() on the search() path excluding existing one
      ## in the global environment?
      e <- globalenv()
      while (!identical(e <- parent.env(e), emptyenv())) {
        if (exists(".First", mode = "function", envir = e, inherits = FALSE)) {
          .First <- get(".First", mode = "function", envir = e, inherits = FALSE)
          break
        }
      }
      
      if (is.function(.First)) .First()
    }
    env <- new.env(parent = envir)
    env[["preexisting"]] <- first
    env[["tasks"]] <- tasks
    env[["on_session_startup"]] <- TRUE
    environment(.First) <- env
    
    assign(".First", .First, envir = envir)
  
    invisible(tasks)
}
