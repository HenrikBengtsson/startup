#' @describeIn startup Initiate using \file{.Rprofile.d/} files
#' 
#' @aliases rprofile
#' @export
rprofile_d <- function(sibling = FALSE, all = FALSE, unload = FALSE, skip = NA,
                       on_error = c("error", "warning", "immediate.warning",
                                    "message", "ignore"),
                       dryrun = NA, debug = NA, paths = NULL) {
  debug <- debug(debug)

  ## Skip?
  if (is.na(skip)) {
    skip <- any(c("--no-init-file", "--vanilla") %in% commandArgs())
  }

  # (i) Check and fix common errors
  check(all = all, fix = TRUE, debug = FALSE)
  debug(debug)

  if (!skip) {
    # (ii) Source custom .Rprofile.d/* files
    if (is.null(paths)) paths <- find_rprofile_d(sibling = sibling, all = all)
    files <- list_d_files(paths, filter = filter_files)
    source_print_eval <- function(pathname) source(pathname, print.eval = TRUE)
    files_apply(files, fun = source_print_eval,
                on_error = on_error, dryrun = dryrun, what = "Rprofile")

    # (iii) Validate .Rprofile encoding
    check_rprofile_encoding()
  }

  res <- api()
  if (unload) unload()
  invisible(res)
}

#' @export
rprofile <- function(...) {
  .Deprecated(new = "startup::rprofile_d()")
  rprofile_d(...)
}
