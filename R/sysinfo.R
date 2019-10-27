#' Information on the current R session
#'
#' @return A named list.
#'
#' @examples
#' startup::sysinfo()
#'
#' @export
sysinfo <- function() {
  ## Built-in system information (character)
  sysinfo <- as.list(Sys.info())
  sysinfo$os <- .Platform$OS.type
  sysinfo$gui <- .Platform$GUI
  sysinfo$interactive <- interactive()
  
  ## Built-in system flags (logical)
  sysinfo$ess <- is_ess()
  sysinfo$microsoftr <- is_microsoftr()
  sysinfo$pqr <- is_pqr()
  sysinfo$radian <- is_radian()
  ## Deprecated: Renamed rtichoke -> radian in December 2018
  sysinfo$rtichoke <- sysinfo$radian
  ## Deprecated: Renamed rice -> rtichoke in February 2018
  sysinfo$rice <- sysinfo$radian
  sysinfo$rstudio <- is_rstudio_console()
  sysinfo$rstudioterm <- is_rstudio_terminal()
  sysinfo$wine <- is_wine()

  ## Session-specific variables (character)
  sysinfo$dirname <- basename(getwd())
  
  sysinfo
}
