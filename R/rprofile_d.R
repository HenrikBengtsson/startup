#' @describeIn startup Initiate using \file{.Rprofile.d/} files
#'
#' @aliases rprofile
#' @export
rprofile_d <- function(sibling = FALSE, all = FALSE, check = NA,
                       unload = FALSE, skip = NA,
                       on_error = c("error", "warning", "immediate.warning",
                                    "message", "ignore"),
                       dryrun = NA, debug = NA, paths = NULL) {
  debug <- debug(debug)

  if (is.na(check)) {
    check <- as.logical(Sys.getenv("R_STARTUP_CHECK", "TRUE"))
    check <- isTRUE(getOption("startup.check", check))
  }

  # (i) Check and fix common errors
  if (check) {
    check(all = all, fix = TRUE, debug = FALSE)
  }

  debug(debug)

  # (ii) Find custom .Rprofile.d/* files
  if (is.null(paths)) paths <- find_rprofile_d(sibling = sibling, all = all)

  # (iii) Filter and source custom .Rprofile.d/* files
  files <- list_d_files(paths, filter = filter_files)

  if (is.na(skip)) {
    skip <- any(c("--no-init-file", "--vanilla") %in% commandArgs())
    if (skip) {
      logf(" - Skipping %d .Rprofile.d/* scripts, because R was launched with command-line option %s", length(files), paste(intersect(c("--no-init-file", "--vanilla"), commandArgs()), collapse = " "))
    }
  } else if (skip) {
    logf(" - Skipping %d .Rprofile.d/* scripts because skip = TRUE", length(files))
  }
  
  ## Skip?
  if (!skip) {
    encoding <- getOption("encoding")
    keep_source <- getOption("keep.source", TRUE)

    source_print_eval <- function(pathname) {
      current_script_pathname(pathname)
      on.exit(current_script_pathname(NA_character_))
      source(pathname, encoding = encoding, local = FALSE, chdir = FALSE,
             print.eval = TRUE,
             keep.source = keep_source, echo = FALSE, verbose = FALSE)
    }
    
    files_apply(files, fun = source_print_eval,
                on_error = on_error, dryrun = dryrun, what = "Rprofile",
                debug = debug)
  }

  res <- api()
  if (unload) unload()
  invisible(res)
}
