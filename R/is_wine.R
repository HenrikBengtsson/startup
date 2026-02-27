#' Check if running R on Windows using Wine
#'
#' @return A logical
#'
#' @references
#' 1. Wine Developer FAQ, How can I detect Wine?,
#'    \url{https://gitlab.winehq.org/wine/wine/-/wikis/Developer-FAQ#How_can_I_detect_Wine.3F}
#' 2. Jeff Zaroyko, Detecting Wine, Wine Devel mailing list, 2008-09-29,
#'    \url{https://www.winehq.org/pipermail/wine-devel/2008-September/069389.html}
is_wine <- function() {
  if (.Platform$OS.type != "windows") return(FALSE)
  any(grepl("^WINE", names(Sys.getenv())))
}
