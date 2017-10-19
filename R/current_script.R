#' Gets the pathname of the currently running startup script
#'
#' @return A character string
#' 
#' @export
current_script <- function() {
  current_script_pathname()
}

current_script_pathname <- local({
  .pathname <- NA_character_
  function(pathname = NULL) {
    if (is.null(pathname)) {
      pathname <- .pathname
    } else {
      .pathname <<- pathname
    }
    pathname
  }
})
