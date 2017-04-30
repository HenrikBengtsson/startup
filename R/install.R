#' Install and uninstall support for .Renviron.d and .Rprofile.d startup
#' directories
#'
#' Install and uninstall support for \file{.Renviron.d} and \file{.Rprofile.d}
#' startup directories by appending / removing one line of code to the
#' \file{~/.Rprofile} file.
#'
#' @param path The path where to create / update the \file{.Rprofile} file.
#'
#' @param backup If \code{TRUE}, a timestamped backup copy of the original
#' file is created before modifying it, otherwise not.
#'
#' @param debug If \code{TRUE}, debug messages are outputted, otherwise not.
#'
#' @describeIn install Appends a \code{try(startup::startup())} call to the
#' \file{.Rprofile}.
#' @export
install <- function(path = "~", backup = TRUE, debug = FALSE) {
  debug(debug)

  dir <- file.path(path, ".Rprofile.d")
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)

  dir <- file.path(path, ".Renviron.d")
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)

  if (is_installed(path = path)) return(FALSE)

  file <- file.path(path, ".Rprofile")
  if (backup && file.exists(file)) backup(file)
  cat("try(startup::startup())\n", file = file, append = TRUE)
  TRUE
}


#' @describeIn install Remove calls to \code{startup::startup()} and similar.
#' @export
uninstall <- function(path = "~", backup = TRUE, debug = FALSE) {
  debug(debug)
  if (!is_installed(path = path)) return(FALSE)
  file <- file.path(path, ".Rprofile")
  bfr <- readLines(file, warn = FALSE)
  pattern <- "startup::(startup|renviron|rprofile)[(].*[)]"
  bfr2 <- grep(pattern, bfr, value = TRUE, invert = TRUE)
  ## Nothing to do?
  if (isTRUE(all.equal(bfr2, bfr))) return(TRUE)
  if (backup) backup(file)
  writeLines(bfr2, con = file)
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
