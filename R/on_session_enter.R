#' Register R expressions and functions to be evaluated at the end of the R startup process
#' 
#' @param expr,substitute An R expression or a function.
#' If `substitute = TRUE`, `expr` is automatically substituted. 
#' `NULL` expressions are ignored.
#'
#' @param append If TRUE (default), the expression or the function will be
#' evaluated after previously registered entries, otherwise prepended.
#'
#' @param replace if TRUE, the expression or the function replaces all
#' existing ones previously added, otherwise it will be added (default).
#'
#' @return (invisible) the list of registered expressions and functions.
#'
#' @details
#' This function registers one or more R expressions or functions to be
#' evaluated at the very end of the R startup process.  All of them are
#' evaluated in a local environment.  These expressions and functions are
#' evaluated without exception handlers, which means that if one produces an
#' error, then none of the following will be evaluated.
#'
#' To list currently registered expressions and functions, call
#' `exprs <- on_session_enter()`. To remove all registered entries, call
#' `on_session_enter(replace = TRUE)`.
#'
#' The function works by recording all `expr` in an internal list which will
#' be evaluated via a custom \code{\link[base:.First]{.First()}} function
#' created in the global environment. Any other `.First()` function on the
#' search path, including a pre-existing `.First()` function in the global
#' environment, is called at the end after registered expressions have been
#' called.
#'
#' @export
on_session_enter <- function(expr = NULL, substitute = TRUE, append = TRUE, replace = FALSE) {
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
      if (isTRUE(env[["on_session_enter"]])) {
        first <- env[["first"]]
        tasks <- env[["tasks"]]
      }
    }

    ## Replace?
    if (replace) tasks <- list()
  
    ## Append or prepend?
    if (!is.null(expr)) {
      ## A function?
      if (identical(expr[[1]], as.symbol("function"))) {
        expr <- eval(expr, envir = parent.frame())
      }
      task <- list(expr)
      tasks <- if (append) c(tasks, task) else c(task, tasks)
    }

    .First <- function() {
      "This function was added by startup::on_session_enter()"
      "Evaluate registered expressions, cf. environment(.First)$tasks"
      for (task in tasks) {
        if (is.function(task)) {
          local(eval(task(), envir = parent.frame()))
        } else {
          local(eval(task, envir = parent.frame()))
        }
      }
      
      ## Call any pre-existing .First() on the search path
      "Call any pre-existing .First() on the search path, including"
      "any pre-existing .First() function, cf. environment(.First)$first"
      
      ## Is there a .First() on the search() path excluding existing one
      ## in the global environment?
      e <- globalenv()
      while (!identical(e <- parent.env(e), emptyenv())) {
        if (exists(".First", mode = "function", envir = e, inherits = FALSE)) {
          first <- get(".First", mode = "function", envir = e, inherits = FALSE)
          break
        }
      }
      
      if (is.function(first)) first()
    }
    env <- new.env(parent = envir)
    env[["first"]] <- first
    env[["tasks"]] <- tasks
    env[["on_session_enter"]] <- TRUE
    environment(.First) <- env
    
    assign(".First", .First, envir = envir)
  
    invisible(tasks)
}
