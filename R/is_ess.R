#' Checks whether running R via Emacs Spekas Statistics (ESS) or not
#'
#' @return A logical
is_ess <- function() {
  is.element("ESSR", search())
}
