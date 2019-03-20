#' @describeIn startup Initiate using \file{.Renviron.d/} files
#'
#' @param paths (internal) character vector of directories.
#'
#' @aliases renviron
#' @export
renviron_d <- function(sibling = FALSE, all = FALSE, unload = FALSE, skip = NA,
                       dryrun = NA, debug = NA, paths = NULL) {
  debug(debug)

  ## Skip?
  if (is.na(skip)) {
    skip <- any(c("--no-environ", "--vanilla") %in% commandArgs())
  }

  if (!skip) {
    read_renviron <- function(pathname) {
      readRenviron(pathname)
      agenda_pathname <- mark_if_agenda_file(pathname)
      if (length(agenda_pathname) == 1L) {
        when <- attr(agenda_pathname, "when")
        attr(pathname, "note") <- sprintf("%s file processed (timestamp file %s)", sQuote(when), sQuote(agenda_pathname))
      }
      pathname
    }
    
    # Load custom .Renviron.d/* files
    if (is.null(paths)) paths <- find_renviron_d(sibling = sibling, all = all)
    files <- list_d_files(paths, filter = filter_files)    
    files_apply(files, fun = read_renviron, dryrun = dryrun, what = "Renviron")
  }

  res <- api()
  if (unload) unload()
  invisible(res)
}

#' @export
renviron <- function(...) .Defunct(new = "startup::renviron_d()")
