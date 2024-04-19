#' Check if running R via radian (formerly known as rtichoke and rice)
#'
#' @return A logical
#'
#' @references
#' 1. radian - A 21 century R console (previously known as rtichoke and rice),
#'    \url{https://github.com/randy3k/radian}
is_radian <- function() {
  ## radian (>= 0.3.0)
  if (nzchar(Sys.getenv("RADIAN_VERSION"))) return(TRUE)
  
  ## rtichoke (< 0.3.0)
  if (nzchar(Sys.getenv("RTICHOKE_VERSION"))) return(TRUE)
  
  ## rice (<= 0.1.1)
  if (nzchar(Sys.getenv("RICE_VERSION"))) return(TRUE)
  ## rice (< 0.0.9)
  tolower(basename(Sys.getenv("_"))) == "rice"
}
