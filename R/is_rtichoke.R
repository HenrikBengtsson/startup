#' Checks whether running R via rtichoke (formerly rice) or not
#'
#' @return A logical
#'
#' @references
#' 1. rtichoke - A 21 century R console (previously known as rice),
#'    \url{https://github.com/randy3k/rtichoke}
is_rtichoke <- function() {
  if (nzchar(Sys.getenv("RTICHOKE_VERSION"))) return(TRUE)
  ## For rice (<= 0.1.1)
  if (nzchar(Sys.getenv("RICE_VERSION"))) return(TRUE)
  ## For rice (< 0.0.9)
  tolower(basename(Sys.getenv("_"))) == "rice"
}
