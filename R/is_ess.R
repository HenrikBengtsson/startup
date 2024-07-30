#' Check if running R via Emacs Speaks Statistics (ESS)
#'
#' @return A logical
is_ess <- function() {
  is.element("ESSR", search())
}
