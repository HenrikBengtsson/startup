#' Checks if running R via Visual Studio Code (VSCode)
#'
#' @return A logical
is_vscode <- function() {
  opt_names <- names(options())
  "vsc.globalenv" %in% opt_names
}
