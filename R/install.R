#' Install and uninstall support for .Renviron.d and .Rprofile.d startup
#' directories
#'
#' Install and uninstall support for \file{.Renviron.d} and \file{.Rprofile.d}
#' startup directories by appending / removing one line of code to the
#' \file{~/.Rprofile} file.
#'
#' @param path The path where to create / update the \file{.Rprofile} file.
#'
#' @param backup If `TRUE`, a timestamped backup copy of the original file is
#' created before modifying / overwriting it, otherwise not.  If the backup
#' fails, then an error is produced and the R startup file is unmodified.
#'
#' @param overwrite If the R startup file already exist, then `FALSE` (default)
#' appends the startup code to the end of the file. is overwritten.  If `TRUE`,
#' any pre-existing R startup file is overwritten.
#'
#' @param quiet If `FALSE` (default), detailed messages are generated,
#' otherwise not.
#'
#' @return The pathname of the R startup file modified.
#'
#' @describeIn install injects a `try(startup::startup())` call to the
#' \file{.Rprofile} file (created if missing) and creates empty folders
#' \file{.Renviron.d/} and \file{.Rprofile.d/}, if missing.
#'
#' @export
install <- function(path = "~", backup = TRUE, overwrite = FALSE,
                    quiet = FALSE) {
  if (quiet) notef <- function(...) NULL

  dir <- file.path(path, ".Rprofile.d")
  if (!file.exists(dir)) {
    notef("Creating R profile directory: %s", sQuote(dir))
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  }

  dir <- file.path(path, ".Renviron.d")
  if (!file.exists(dir)) {
    notef("Creating R environment directory: %s", sQuote(dir))
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  }

  file <- file.path(path, ".Rprofile")
  if (is_installed(file)) {
    msg <- sprintf("startup::startup() already installed: %s", sQuote(file))
    notef(msg)
    warning(msg)
    return(file)
  }


  file_exists <- file.exists(file)
  if (backup && file_exists) backup(file, quiet = quiet)

  code <- "try(startup::startup())\n"

  ## If the .Rprofile file does not have a newline at the end, which is
  ## a mistake, make sure that the appended startup code is on its own line
  if (file_exists && !eof_ok(file)) code <- paste0("\n", code)
  
  cat(code, file = file, append = !overwrite)
  if (file_exists) {
    notef("%s 'try(startup::startup())' to already existing R startup file: %s",
          if (overwrite) "Appended" else "Added", sQuote(file))
  } else {
    notef("Created new R startup file with 'try(startup::startup())': %s",
          sQuote(file))
  }

  file
}


#' @describeIn install Remove calls to `startup::startup()` and similar.
#' @export
uninstall <- function(path = "~", backup = TRUE, quiet = FALSE) {
  if (quiet) notef <- function(...) NULL

  file <- file.path(path, ".Rprofile")
  if (!is_installed(file)) {
    msg <- sprintf("startup::startup() not installed: %s", sQuote(file))
    notef(msg)
    warning(msg)
    return(file)
  }

  bfr <- readLines(file, warn = FALSE)
  pattern <- "startup::(startup|renviron|rprofile)[(].*[)]"
  bfr2 <- grep(pattern, bfr, value = TRUE, invert = TRUE)
  ## Nothing to do?
  if (isTRUE(all.equal(bfr2, bfr))) {
    msg <- sprintf("startup::startup() not installed: %s", sQuote(file))
    notef(msg)
    warning(msg)
    return(file)
  }
  if (backup) backup(file, quiet = quiet)
  writeLines(bfr2, con = file)
  notef("R startup file updated: %s", sQuote(file))

  file
}


is_installed <- function(file = file.path("~", ".Rprofile")) {
  if (!file.exists(file)) return(FALSE)
  bfr <- readLines(file, warn = FALSE)
  bfr <- gsub("#.*", "", bfr)
  pattern <- "startup::(startup|renviron|rprofile)[(].*[)]"
  res <- any(grepl(pattern, bfr))
  attr(res, "file") <- file
  res
}
