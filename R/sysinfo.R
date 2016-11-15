#' Information on the current R Session
#'
#' @return A named list.
#'
#' @examples
#' startup::sysinfo()
#'
#' @export
sysinfo <- function() {
  sysinfo <- as.list(Sys.info())
  
  sysinfo$os <- .Platform$OS.type
  sysinfo$interactive <- interactive()
  
  sysinfo
}


