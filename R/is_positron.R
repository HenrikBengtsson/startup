#' Checks if running R via Positron
#'
#' @return A logical
is_positron <- function() {
  (Sys.getenv("POSITRON") == "1") && !nzchar(Sys.getenv("POSITRON_VERSION"))
}
