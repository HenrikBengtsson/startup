#' Check if running R via Microsoft R Open
#'
#' @return A logical
is_microsoftr <- function() {
  exists("Revo.version", mode = "list", envir = baseenv(), inherits = FALSE)
}
