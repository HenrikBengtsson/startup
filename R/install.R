#' Install and uninstall startup to .Rprofile
#'
#' @param path The path where to create / update the \file{.Rprofile} file.
#' @param debug If \code{TRUE}, debug messages are outputted, otherwise not.
#'
#' @describeIn install Appends a \code{startup::startup()} call to the \file{.Rprofile}.
#' @export
install <- function(path = "~", debug = FALSE) {
  debug(debug)
  if (is_installed(path = path)) return(FALSE)
  file <- file.path(path, ".Rprofile")
  cat("startup::startup()\n", file = file, append = TRUE)
  TRUE
}


#' @describeIn install Remove calls to \code{startup::startup()} and similar.
#' @export
uninstall <- function(path = "~", debug = FALSE) {
  debug(debug)
  if (!is_installed(path = path)) return(FALSE)
  file <- file.path(path, ".Rprofile")
  bfr <- readLines(file, warn = FALSE)
  pattern <- "startup::(startup|renviron|rprofile)[(].*[)]"
  bfr <- grep(pattern, bfr, value = TRUE, invert = TRUE)
  writeLines(bfr, con = file)
  TRUE
}


is_installed <- function(path = "~", debug = FALSE) {
  debug(debug)
  file <- file.path(path, ".Rprofile")
  if (!file.exists(file)) return(FALSE)
  bfr <- readLines(file, warn = FALSE)
  bfr <- gsub("#.*", "", bfr)  
  pattern <- "startup::(startup|renviron|rprofile)[(].*[)]"
  any(grepl(pattern, bfr))
}
