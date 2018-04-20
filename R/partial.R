#' Partially Apply a Function by Setting One Or More of the Arguments
#' 
#' @param fun A function.
#'
#' @param \ldots Named arguments of `fun` to be set or modified.
#' 
#' @return A function.
#'
#' @examples
#' ## Create ll() as ls() but with all.names = TRUE
#' ll <- startup::partial(ls, all.names = TRUE)
#'
#' @export
partial <- function(fun, ...) {
  if (!is.function(fun))
    stop("Argument 'fun' is not a function: ", mode(fun)[1])

  args <- list(...)
  for (name in names(args)) {
    formals(fun)[name] <- args[name]
  }
  
  fun
}
