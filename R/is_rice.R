#' Checks whether running R via Rice or not
#'
#' @return A logical
#'
#' @references
#' 1. Rice - A Command-Line Interface for R,
#'    \url{https://github.com/randy3k/Rice}
is_rice <- function() {
  if (nzchar(Sys.getenv("RICE_VERSION"))) return(TRUE)
  ## For rice (< 0.0.9)
  tolower(basename(Sys.getenv("_"))) == "rice"
}
