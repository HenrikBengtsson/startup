#' Checks if running R via Alternative R Frontend (arf)
#'
#' @return A logical
is_arf <- function() {
  basename(commandArgs()[1]) == "arf"
}
