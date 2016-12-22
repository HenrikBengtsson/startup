#' Checks whether running R via RStudio or not
#'
#' @return A logical
#'
#' @references
#' \itemize{
#'  \item Kevin Ushey (RStudio), Check if R is running in RStudio, Stackoverflow, 2016-09-23, \url{http://stackoverflow.com/questions/12389158/check-if-r-is-running-in-rstudio#comment66636507_35849779}
#' }
is_rstudio <- function() {
  (Sys.getenv("RSTUDIO") == "1")
}
