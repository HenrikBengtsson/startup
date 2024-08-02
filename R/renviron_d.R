#' @describeIn startup Initiate using \file{.Renviron.d/} files
#'
#' @param paths (internal) character vector of directories.
#'
#' @aliases renviron
#' @export
renviron_d <- function(sibling = FALSE, all = FALSE, unload = FALSE, skip = NA,
                       dryrun = NA, debug = NA, paths = NULL) {
  debug(debug)

  # (i) Find custom .Renviron.d/* files
  if (is.null(paths)) paths <- find_renviron_d(sibling = sibling, all = all)
  
  # (ii) Filter and source custom .Renviron.d/* files
  files <- list_d_files(paths, filter = filter_files)    

  if (is.na(skip)) {
    skip <- any(c("--no-environ", "--vanilla") %in% commandArgs())
    if (skip) {
      logf(" - Skipping %d .Renviron.d/* files, because R was launched with command-line option %s", length(files), paste(intersect(c("--no-environ", "--vanilla"), commandArgs()), collapse = " "))
    }
  } else if (skip) {
    logf(" - Skipping %d .Renviron.d/* files because skip = TRUE", length(files))
  }

  if (!skip) {
    # Load custom .Renviron.d/* files
    files_apply(files, fun = readRenviron,
                dryrun = dryrun, what = "Renviron",
                debug = debug)
  }

  res <- api()
  if (unload) unload()
  invisible(res)
}
