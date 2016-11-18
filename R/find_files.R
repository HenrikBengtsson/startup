#' Locates the .Rprofile and .Renviron files used during the startup of R
#'
#' @describeIn find_rprofile Locates the \file{.Rprofile} file used during \R startup.
#' @export
#' @keywords internal
find_rprofile <- function(all = FALSE) {
  pathnames <- c(Sys.getenv("R_PROFILE_USER"), "./.Rprofile", "~/.Rprofile")
  find_files(pathnames, all = all)
}

#' @describeIn find_rprofile Locates the \file{.Renviron} file used during \R startup.
#' @export
#' @keywords internal
find_renviron <- function(all = FALSE) {
  pathnames <- c(Sys.getenv("R_ENVIRON_USER"), "./.Renviron", "~/.Renviron")
  find_files(pathnames, all = all)
}

#' Locates the .Rprofile.d and .Renviron.d directories used during the startup of R
#'
#' @describeIn find_rprofile_d Locates the \file{.Rprofile.d} directory used during \R startup.
#' @export
#' @keywords internal
find_rprofile_d <- function(all = FALSE) {
  if (all) {
    pathnames <- c(Sys.getenv("R_PROFILE_USER"), "./.Rprofile", "~/.Rprofile")
  } else {
    pathnames <- find_rprofile(all = FALSE)
    if (length(pathnames) == 0) {
      logf("Found no .Rprofile file on the R startup search path. Will search for .Rprofile.d directory located anywhere on the search path")
      pathnames <- c(Sys.getenv("R_PROFILE_USER"), "./.Rprofile", "~/.Rprofile")
    } else {
      logf("Found %s on the R startup search path. Will look for the .Rprofile.d directory in the same location only", pathnames)
    }
  }

  pathnames <- pathnames[nzchar(pathnames)]
  paths <- sprintf("%s.d", pathnames)
  logf("Looking for %s", paste(sQuote(paths), collapse = ", "))
  find_d_dirs(paths, all = all)
}

#' @describeIn find_rprofile_d Locates the \file{.Renviron.d} directory used during \R startup.
#' @export
#' @keywords internal
find_renviron_d <- function(all = FALSE) {
  if (all) {
    pathnames <- c(Sys.getenv("R_ENVIRON_USER"), "./.Renviron", "~/.Renviron")
  } else {
    pathnames <- find_renviron(all = FALSE)
    if (length(pathnames) == 0) {
      logf("Found no .Renviron file on the R startup search path. Will search for .Renviron.d directory located anywhere on the search path")
      pathnames <- c(Sys.getenv("R_ENVIRON_USER"), "./.Renviron", "~/.Renviron")
    } else {
      logf("Found %s on the R startup search path. Will look for the .Renviron.d directory in the same location only", pathnames)
    }
  }
  pathnames <- pathnames[nzchar(pathnames)]
  paths <- sprintf("%s.d", pathnames)
  logf("Looking for %s", paste(sQuote(paths), collapse = ", "))
  find_d_dirs(paths, all = all)
}

find_files <- function(pathnames, all = FALSE) {
  pathnames <- lapply(pathnames, FUN = normalizePath, mustWork = FALSE)
  pathnames <- unlist(pathnames, use.names = FALSE)
  pathnames <- pathnames[file.exists(pathnames)]
  pathnames <- pathnames[!file.info(pathnames)$isdir]

  if (!all) {
    pathnames <- if (length(pathnames) == 0) character(0L) else pathnames[1]
  }

  pathnames
} ## find_files()

find_d_dirs <- function(paths, all = FALSE) {
  if (length(paths) == 0) return(character(0))
  
  paths <- lapply(paths, FUN = normalizePath, mustWork = FALSE)
  paths <- unlist(paths, use.names = FALSE)
  paths <- paths[file.exists(paths)]
  paths <- paths[file.info(paths)$isdir]

  if (!all) {
    paths <- if (length(paths) == 0) character(0L) else paths[1]
  }

  paths
} ## find_d_dirs()


find_d_files <- function(paths) {
  fileext <- function(x) {
    pos <- regexpr("[.]([[:alnum:]]+)$", x)
    ifelse(pos < 0, "", substring(x, pos + 1L))
  }

  ol <- Sys.getlocale("LC_COLLATE")
  on.exit(Sys.setlocale("LC_COLLATE", ol))
  Sys.setlocale("LC_COLLATE", "C")
  
  ## Keep only the ones that exists
  paths <- paths[file.exists(paths)]

  ## Nothing to do?
  if (length(paths) == 0) return(character(0L))
  
  ## For each directory, locate files of interest
  files <- NULL
  for (path in paths) {
    files <- c(files, dir(path = path, pattern = "[^~]$", recursive = TRUE, all.files = TRUE, full.names = TRUE))
  }

  ## Drop stray files
  files <- files[!is.element(basename(files), c(".Rhistory", ".RData"))]

  ## Drop files based on filename extension
  files <- files[!is.element(fileext(files), c("txt", "md"))]

  ## Keep only existing files
  files <- files[file.exists(files)]
  files <- files[!file.info(files)$isdir]

  ## Drop duplicates
  files <- normalizePath(files)
  files <- unique(files)

  files
} ## find_d_files()
