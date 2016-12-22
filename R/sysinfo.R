#' Information on the current R session
#'
#' @return A named list.
#'
#' @examples
#' startup::sysinfo()
#'
#' @export
sysinfo <- function() {
  ## Built-in information
  sysinfo <- as.list(Sys.info())
  sysinfo$os <- .Platform$OS.type
  sysinfo$gui <- .Platform$GUI
  sysinfo$interactive <- interactive()

  ## Additional information
  sysinfo$rstudio <- is_rstudio()
  sysinfo$wine <- is_wine()
  
  sysinfo
}


