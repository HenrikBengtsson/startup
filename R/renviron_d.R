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
    # Load custom .Renviron.d/* files
    if (is.null(paths)) paths <- find_renviron_d(sibling = sibling, all = all)
    files <- list_d_files(paths, filter = filter_files)
    files_apply(files, fun = readRenviron, dryrun = dryrun, what = "Renviron")
  }

  res <- api()
  if (unload) unload()
  invisible(res)
}

#' @export
renviron <- function(...) {
  .Deprecated(new = "startup::renviron_d()")
  renviron_d(...)
}
