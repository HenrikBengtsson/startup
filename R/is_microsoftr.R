#' Checks if running R in Microsoft R Open
#'
#' @return A logical
is_microsoftr <- function() {
  ## FIXME: In what namespace should we look? /HB 2018-03-05
  exists("Revo.version", mode = "list")
}
