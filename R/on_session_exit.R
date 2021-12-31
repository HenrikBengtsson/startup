#' Register R expressions and functions to be evaluated when R terminates
#' 
#' @param fcn An R function or an R expression.  If an expression, it will
#' automatically we wrapped up in an anonymous function.
#'
#' @param append If TRUE (default), the function will be evaluated after
#' previously registered ones, otherwise prepended.
#'
#' @param replace if TRUE, the function replaces any previously registered
#' ones, otherwise it will be added (default).
#'
#' @return (invisible) the list of registered functions.
#'
#' @details
#' This function registers one or more functions to be called when the R
#' session terminates.  All of them are evaluated in a local environment.
#' These functions are evaluated without exception handlers, which means that
#' if one produces an error, then none of the following will be evaluated.
#'
#' To list currently registered functions, call `fcns <- on_session_exit()`.
#' To remove all registered functions, call `on_session_exit(replace = TRUE)`.
#'
#' The function works by recording all `fcn`:s in an internal list which will
#' be evaluated via a custom function that is called when the global
#' environment is garbage collected, which happens at the very end of the R
#' shutdown process.
#' Contrary to `.Last()` and `.Last.sys()`, which may not be called if
#' `quit(runLast = FALSE)` is used, functions registered via
#' `on_session_exit()` are always processed.
#'
#' @export
on_session_exit <- local({
  .globalenv_finalizer <- function(env) {
    "This function was added by startup::on_session_exit()"
    "Evaluate registered expressions and function, cf."
    "fcns <- startup::on_session_exit()"
    for (fcn in fcns) {
      local(eval(fcn(), envir = parent.frame()))
    }
  }
  
  function(fcn = NULL, append = TRUE, replace = FALSE) {
    stopifnot(is.logical(append), length(append) == 1L, !is.na(append))
    stopifnot(is.logical(replace), length(replace) == 1L, !is.na(replace))

    if (!is.function(fcn)) {
      expr <- fcn
      fcn <- function() NULL
      body(fcn) <- expr
    }

    env <- environment(.globalenv_finalizer)
    
    ## Registered finalizer? (only once)
    if (!isTRUE(env[["on_session_exit"]])) {
      env <- new.env(parent = globalenv())
      env[["fcns"]] <- list()
      environment(.globalenv_finalizer) <<- env
      reg.finalizer(globalenv(), .globalenv_finalizer, onexit = TRUE)
      env[["on_session_exit"]] <- TRUE
    }

    fcns <- env[["fcns"]]
    if (is.null(fcn)) return(fcns)

    ## Replace?
    if (replace) fcns <- list()
  
    ## Append or prepend?
    if (!is.null(fcn)) {
      fcn <- list(fcn)
      fcns <- if (append) c(fcns, fcn) else c(fcn, fcns)
    }

    env[["fcns"]] <- fcns

    invisible(fcns)
  }
})

