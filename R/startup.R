#' Simplified Initialization at Start of an R Session
#'
#' @examples
#' \dontrun{
#' # Initiate just .Renviron.d/ files
#' startup::renviron()
#'
#' # Initiate just .Rprofile.d/ files
#' startup::rprofiled()
#'
#' # Initiate .Renviron.d/ files then .Rprofile.d/ files
#' startup::renviron()$rprofile()
#'
#' # Initiate everything (as above in the same order)
#' startup::everything()
#'   
#' # Initiate everything and unload package afterward
#' startup::everything()$unload()
#' }
#'
#' @rdname startup
#' @name startup
NULL

#' Initiate .Renviron.d/ files then .Rprofile.d/ files
#'
#' @rdname startup
#' @export
everything <- function() {
  # (i) Load custom .Renviron.d/* files
  renviron()
  
  # (ii) Load custom .Rprofile.d/* files
  rprofile()
  
  invisible(api())
}

#' Initiate .Renviron.d/ files
#'
#' @rdname startup
#' @export
renviron <- function() {
  # Load custom .Renviron.d/* files
  startup_apply(".Renviron", FUN = readRenviron)
  invisible(api())
}

#' Initiate .Rprofile.d/ files
#'
#' @rdname startup
#' @export
rprofile <- function() {
  # (a) Load custom .Rprofile.d/* files
  startup_apply(".Rprofile", FUN = source)
  # (b) Validate .Rprofile
  check_rprofile()
  invisible(api())
}
