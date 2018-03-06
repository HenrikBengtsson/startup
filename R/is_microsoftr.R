#' Checks if running R in Microsoft R Open
#'
#' @return A logical
is_microsoftr <- function() {
  exists("Revo.version", mode = "list", envir = baseenv(), inherits = FALSE)
}
