# Register functions to be evaluated at the beginning or end of the R session

Register functions to be evaluated at the beginning or end of the R
session

## Usage

``` r
on_session_enter(fcn = NULL, append = TRUE, replace = FALSE)

on_session_exit(fcn = NULL, append = TRUE, replace = FALSE)
```

## Arguments

- fcn:

  A function or an R expression. The function must accept zero or more
  arguments (currently not used). If an expression, it will
  automatically be wrapped up in an anonymous function.

- append:

  If TRUE (default), the function will be evaluated after previously
  registered ones, otherwise prepended.

- replace:

  if TRUE, the function replaces any previously registered ones,
  otherwise it will be added (default).

## Value

(invisible) the list of registered functions.

## Details

These functions register one or more functions to be called when the
current R session begins or ends. The functions are evaluated in a local
environment and without exception handlers, which means that if one
produces an error, then none of the succeeding functions will be called.

To list currently registered functions, use `fcns <- on_session_enter()`
or `fcns <- on_session_exit()`. To remove all registered functions, use
`on_session_enter(replace = TRUE)` or `on_session_exit(replace = TRUE)`.

The `on_session_enter()` function works by recording all `fcn`:s in an
internal list which will be evaluated via a custom
[`.First()`](https://rdrr.io/r/base/Startup.html) function created in
the global environment. Any other `.First()` function on the search
path, including a pre-existing `.First()` function in the global
environment, is called at the end after registered functions have been
called.

The `on_session_exit()` function works by recording all `fcn`:s in an
internal list which will be evaluated via a custom function that is
called when the global environment is garbage collected, which happens
at the very end of the R shutdown process. Contrary to a
[`.Last()`](https://rdrr.io/r/base/quit.html) function, which is not
called if `quit(runLast = FALSE)` is used, functions registered via
`on_session_exit()` are always processed. Registered `on_session_exit()`
functions are called *after*
[`quit()`](https://rdrr.io/r/base/quit.html) saves any workspace image
to file (`./.RData`), and *after* any `.Last()` has been called.

## Examples

``` r
if (FALSE) { # \dontrun{
## Summarize interactive session upon termination
if (interactive()) {
  startup::on_session_exit(local({
    t0 <- Sys.time()
    function(...) {
      dt <- difftime(Sys.time(), t0, units = "auto")
      msg <- c(
        "Session summary:",
        sprintf(" * R version: %s", getRversion()),
        sprintf(" * Process ID: %d", Sys.getpid()),
        sprintf(" * Wall time: %.2f %s", dt, attr(dt, "units"))
      )
      msg <- paste(msg, collapse = "\n")
      message(msg)
    }
  }))
}
} # }
```
