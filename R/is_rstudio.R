#' Checks if running R in RStudio Console or RStudio Terminal
#'
#' @return A logical
#'
#' @references
#' 1. Kevin Ushey (RStudio), Check if R is running in RStudio,
#'    Stackoverflow, 2016-09-23,
#'    \url{https://stackoverflow.com/questions/12389158/check-if-r-is-running-in-rstudio#comment66636507_35849779}
#' 2. Jonathan McPherson (RStudio), Programmatically detect RStudio Terminal vs RStudio Console?,
#'    RStudio Community - RStudio IDE, 2018-01-10,
#'    \url{https://forum.posit.co/t/programmatically-detect-rstudio-terminal-vs-rstudio-console/4107}
is_rstudio_console <- function() {
  (Sys.getenv("RSTUDIO") == "1") && !nzchar(Sys.getenv("RSTUDIO_TERM"))
}

is_rstudio_terminal <- function() {
  (Sys.getenv("RSTUDIO") == "1") &&  nzchar(Sys.getenv("RSTUDIO_TERM"))
}
