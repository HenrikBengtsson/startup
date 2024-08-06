#' Checks if running R via Ark (An R Kernel)
#'
#' @return A logical
is_ark <- function() {
  basename(commandArgs()[1]) == "ark"
}
