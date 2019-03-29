#' Locates the .Rprofile and .Renviron files used during the startup of R
#'
#' @describeIn find_rprofile Locates the \file{.Rprofile} file used during
#' \R startup.
#'
#' @export
#' @keywords internal
find_rprofile <- function(all = FALSE) {
  pathnames <- c(Sys.getenv("R_PROFILE_USER"), "./.Rprofile", "~/.Rprofile")
  find_files(pathnames, all = all)
}

#' @describeIn find_rprofile Locates the \file{.Renviron} file used during
#' \R startup.
#'
#' @export
#' @keywords internal
find_renviron <- function(all = FALSE) {
  pathnames <- c(Sys.getenv("R_ENVIRON_USER"), "./.Renviron", "~/.Renviron")
  find_files(pathnames, all = all)
}

#' Locates the .Rprofile.d and .Renviron.d directories used during the
#' startup of R
#'
#' @describeIn find_rprofile_d Locates the \file{.Rprofile.d} directory used
#' during \R startup.
#'
#' @export
#' @keywords internal
find_rprofile_d <- function(sibling = FALSE, all = FALSE) {
  ## Only include .Rprofile.d directories if a sibling .Rprofile file exists?
  if (sibling) {
    pathnames <- find_rprofile(all = all)
  } else {
    ## The default R startup search path
    pathnames <- c(Sys.getenv("R_PROFILE_USER"), "./.Rprofile", "~/.Rprofile")
  }

  pathnames <- pathnames[nzchar(pathnames)]
  paths <- sprintf("%s.d", pathnames)
  paths_d <- find_d_dirs(paths, all = all)
  if (length(paths_d) == 0) {
    logf("Found no corresponding startup directory %s.",
         paste(sQuote(paths), collapse = ", "))
  } else {
    logf("Found startup directory %s.", paste(sQuote(paths_d), collapse = ", "))
  }
  paths_d
}

#' @describeIn find_rprofile_d Locates the \file{.Renviron.d} directory used
#' during \R startup.
#'
#' @export
#' @keywords internal
find_renviron_d <- function(sibling = FALSE, all = FALSE) {
  ## Only include .Renviron.d directories if a sibling .Renviron file exists?
  if (sibling) {
    pathnames <- find_renviron(all = all)
  } else {
    ## The default R startup search path
    pathnames <- c(Sys.getenv("R_ENVIRON_USER"), "./.Renviron", "~/.Renviron")
  }

  pathnames <- pathnames[nzchar(pathnames)]
  paths <- sprintf("%s.d", pathnames)
  paths_d <- find_d_dirs(paths, all = all)
  if (length(paths_d) == 0) {
    logf("Found no corresponding startup directory %s.",
         paste(sQuote(paths), collapse = ", "))
  } else {
    logf("Found startup directory %s.", paste(sQuote(paths_d), collapse = ", "))
  }
  paths_d
}

find_files <- function(pathnames, all = FALSE) {
  pathnames <- pathnames[file.exists(pathnames)]
  pathnames <- pathnames[!file.info(pathnames)$isdir]

  if (!all) {
    pathnames <- if (length(pathnames) == 0) character(0L) else pathnames[1]
  }

  pathnames
} ## find_files()

find_d_dirs <- function(paths, all = FALSE) {
  if (length(paths) == 0) return(character(0))

  paths <- paths[file.exists(paths)]
  paths <- paths[file.info(paths)$isdir]

  if (!all) {
    paths <- if (length(paths) == 0) character(0L) else paths[1]
  }

  paths
} ## find_d_dirs()


list_d_files <- function(paths, recursive = TRUE, filter = NULL) {
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
    files <- c(files, dir(path = path, pattern = "[^~]$",
                          recursive = recursive, all.files = TRUE,
                          full.names = TRUE))
  }

  ## Drop files such as '#file.R#'
  files <- files[!grepl("^#.*#$", basename(files))]

  ## Drop stray files created by R
  ignores <- c(".Rhistory", ".RData")
  files <- files[!is.element(basename(files), ignores)]

  ## Drop stray directories and files created by macOS
  ## Source: https://apple.stackexchange.com/questions/14980
  ignores <- c(".DS_Store", ".Spotlight-V100", ".TemporaryItems",
               ".VolumeIcon.icns", ".apDisk", ".fseventsd")
  files <- files[!is.element(basename(files), ignores)]
  files <- grep("[/\\\\](__MACOSX|[.]Trash|[.]Trashes)[/\\\\]", files, value = TRUE,
                fixed = FALSE, invert = TRUE)
  hidden <- grep("._", basename(files), fixed = TRUE, value = FALSE)
  if (length(hidden) > 0) {
    hidden_files <- files[hidden]
    hidden_names <- sub("^[.]_", "", basename(hidden_files))
    hidden_siblings <- file.path(dirname(hidden_files), hidden_names)
    ## Workaround for Windows (because mix of forward and backward slashes)
    hidden_siblings <- normalizePath(hidden_siblings, mustWork = FALSE)
    files_normalized <- normalizePath(files, mustWork = FALSE)
    drop <- is.element(hidden_siblings, files_normalized)
    hidden_files <- hidden_files[drop]
    files <- setdiff(files, hidden_files)
  }

  ## Drop files based on filename endings
  files <- grep("([.]md|[.]txt|~)$", files, value = TRUE, invert = TRUE)

  ## Drop "hidden" private files and "hidden" private directories
  ## (double period)
  files <- grep("(^|/|\\\\)[.][.]", files, value = TRUE, invert = TRUE)

  ## Nothing to do?
  if (length(files) == 0) return(character(0))

  ## Keep only existing files
  files <- files[file.exists(files)]
  files <- files[!file.info(files)$isdir]

  ## Nothing to do?
  if (length(files) == 0) return(character(0))

  ## Drop duplicates
  files_normalized <- normalizePath(files, winslash = "/")
  files <- files[!duplicated(files_normalized)]

  ## Apply filter?
  if (is.function(filter)) {
    files <- filter(files)
  }

  files
} ## list_d_files()
