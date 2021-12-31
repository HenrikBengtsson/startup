#' Register functions to be evaluated at the beginning or end of the R session
#' 
#' @param fcn A function or an R expression. The function must accept zero
#' or more arguments (currently not used). If an expression, it will
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
#' These functions register one or more functions to be called when the
#' current R session begins or ends.  The functions are evaluated in a local
#' environment and without exception handlers, which means that if one
#' produces an error, then none of the succeeding functions will be called.
#'
#' To list currently registered functions, use `fcns <- on_session_enter()`
#' or `fcns <- on_session_exit()`.
#' To remove all registered functions, use `on_session_enter(replace = TRUE)`
#' or `on_session_exit(replace = TRUE)`.
#'
#' The `on_session_enter()` function works by recording all `fcn`:s in an
#' internal list which will be evaluated via a custom
#' \code{\link[base:.First]{.First()}} function created in the global
#' environment. Any other `.First()` function on the search path, including
#' a pre-existing `.First()` function in the global environment, is called
#' at the end after registered functions have been called.
#'
#' The `on_session_exit()` function works by recording all `fcn`:s in an
#' internal list which will be evaluated via a custom function that is called
#' when the global environment is garbage collected, which happens at the very
#' end of the R shutdown process.
#' Contrary to a \code{\link[base:.Last]{.Last()}} function, which is not be
#' called if `quit(runLast = FALSE)` is used, functions registered via
#' `on_session_exit()` are always processed.
#'
#' @export
on_session_enter <- local({
  .First <- function() {
    "This function was added by startup::on_session_enter()"
    "Evaluate registered functions, cf. environment(.First)$fcns"
    for (fcn in fcns) {
      local(eval(fcn(), envir = parent.frame()))
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
  } ## .First()
  
  function(fcn = NULL, append = TRUE, replace = FALSE) {
    stopifnot(is.logical(append), length(append) == 1L, !is.na(append))
    stopifnot(is.logical(replace), length(replace) == 1L, !is.na(replace))

    if (!is.function(fcn)) {
      expr <- fcn
      fcn <- function(...) NULL
      body(fcn) <- expr
    }

    ## Make sure to record any pre-existing .First() in the global environment
    first <- NULL
    fcns <- list()
    env <- NULL

    genv <- globalenv()
    if (exists(".First", envir = genv, inherits = FALSE)) {
      first <- get(".First", envir = genv, inherits = FALSE)
      env <- environment(first)
      if (isTRUE(env[["on_session_enter"]])) {
        first <- env[["first"]]
        fcns <- env[["fcns"]]
      }
    }

    if (is.null(env)) {
      env <- new.env(parent = genv)
      env[["first"]] <- first
      env[["fcns"]] <- fcns
      env[["on_session_enter"]] <- TRUE
      environment(.First) <<- env
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
    
    assign(".First", .First, envir = genv)

    invisible(fcns)
  }
})
