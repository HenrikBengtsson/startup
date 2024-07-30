#' Check if running a Pretty Quick Version of R (pqR)
#'
#' @return A logical
#'
#' @references
#' 1. pqR - a pretty quick version of R,
#'    \url{http://www.pqr-project.org/}
#' 2. GitHub repository for 'pqR'
#'    \url{https://github.com/radfordneal/pqR}
is_pqr <- function() {
  "pqR.base.version" %in% names(R.version)
}
