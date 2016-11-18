#' Locates the .Rprofile and .Renviron files used during the startup of R
#'
#' @describeIn find_rprofile Locates the \file{.Rprofile} file used during \R startup.
#' @export
#' @keywords internal
find_rprofile <- function(first_only = TRUE) {
  pathnames <- c(Sys.getenv("R_PROFILE_USER"), "./.Rprofile", "~/.Rprofile")
  find_files(pathnames, first_only = first_only)
}

#' @describeIn find_rprofile Locates the \file{.Renviron} file used during \R startup.
#' @export
#' @keywords internal
find_renviron <- function(first_only = TRUE) {
  pathnames <- c(Sys.getenv("R_ENVIRON_USER"), "./.Renviron", "~/.Renviron")
  find_files(pathnames, first_only = first_only)
}

#' Locates the .Rprofile.d and .Renviron.d directories used during the startup of R
#'
#' @describeIn find_rprofile_d Locates the \file{.Rprofile.d} directory used during \R startup.
#' @export
#' @keywords internal
find_rprofile_d <- function(first_only = TRUE) {
  pathnames <- c(Sys.getenv("R_PROFILE_USER"), "./.Rprofile", "~/.Rprofile")
  paths <- sprintf("%s.d", pathnames)
  find_dirs(paths, first_only = first_only)
}

#' @describeIn find_rprofile_d Locates the \file{.Renviron.d} directory used during \R startup.
#' @export
#' @keywords internal
find_renviron_d <- function(first_only = TRUE) {
  pathnames <- c(Sys.getenv("R_ENVIRON_USER"), "./.Renviron", "~/.Renviron")
  paths <- sprintf("%s.d", pathnames)
  find_dirs(paths, first_only = first_only)
}

find_files <- function(pathnames, first_only = FALSE) {
  pathnames <- lapply(pathnames, FUN = normalizePath, mustWork = FALSE)
  pathnames <- unlist(pathnames, use.names = FALSE)
  pathnames <- pathnames[file.exists(pathnames)]
  pathnames <- pathnames[!file.info(pathnames)$isdir]

  if (first_only) {
    pathnames <- if (length(pathnames) == 0) character(0L) else pathnames[1]
  }

  pathnames
} ## find_files()

find_dirs <- function(paths, first_only = FALSE) {
  paths <- lapply(paths, FUN = normalizePath, mustWork = FALSE)
  paths <- unlist(paths, use.names = FALSE)
  paths <- paths[file.exists(paths)]
  paths <- paths[file.info(paths)$isdir]

  if (first_only) {
    paths <- if (length(paths) == 0) character(0L) else paths[1]
  }

  paths
} ## find_dirs()
