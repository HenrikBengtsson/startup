#' @rdname on_session_enter
#' @export
on_session_exit <- local({
  .globalenv_finalizer <- function(env) {
    "This function was added by startup::on_session_exit()"
    "Evaluate registered functions, cf. fcns <- startup::on_session_exit()"
    for (fcn in fcns) {
      local(eval(fcn(), envir = parent.frame()))
    }
  }
  
  function(fcn = NULL, append = TRUE, replace = FALSE) {
    stopifnot(is.logical(append), length(append) == 1L, !is.na(append))
    stopifnot(is.logical(replace), length(replace) == 1L, !is.na(replace))

    if (!is.function(fcn)) {
      expr <- fcn
      fcn <- function(...) NULL
      body(fcn) <- expr
    }

    env <- environment(.globalenv_finalizer)
    
    ## Registered finalizer? (only once)
    if (!isTRUE(env[["on_session_exit"]])) {
      env <- new.env(parent = globalenv())
      env[["fcns"]] <- list()
      env[["on_session_exit"]] <- TRUE
      environment(.globalenv_finalizer) <<- env
      reg.finalizer(globalenv(), .globalenv_finalizer, onexit = TRUE)
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

