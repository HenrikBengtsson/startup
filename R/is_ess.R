#' Checks whether running R via Emacs Spekas Statistics (ESS) or not
#'
#' @return A logical
#'
## @references
## \itemize{
##  \item {}
## }
is_ess <- function() {
  (Sys.getenv("EMACS") == "t")
}
