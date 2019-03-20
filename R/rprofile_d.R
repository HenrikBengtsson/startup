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
    check <- getOption("startup.check", check)
  }

  ## Skip?
  if (is.na(skip)) {
    skip <- any(c("--no-init-file", "--vanilla") %in% commandArgs())
  }

  # (i) Check and fix common errors
  if (check) {
    check(all = all, fix = TRUE, debug = FALSE)
  }

  debug(debug)

  if (!skip) {
    # (ii) Source custom .Rprofile.d/* files
    if (is.null(paths)) paths <- find_rprofile_d(sibling = sibling, all = all)
    files <- list_d_files(paths, filter = filter_files)
    encoding <- getOption("encoding")
    
    source_print_eval <- function(pathname) {
      current_script_pathname(pathname)
      on.exit(current_script_pathname(NA_character_))
      source(pathname, encoding = encoding, local = FALSE, chdir = FALSE,
             print.eval = TRUE,
             keep.source = FALSE, echo = FALSE, verbose = FALSE)
      agenda_pathname <- mark_if_agenda_file(pathname)
      if (length(agenda_pathname) == 1L) {
        when <- attr(agenda_pathname, "when")
        attr(pathname, "note") <- sprintf("%s file processed (timestamp file %s)", sQuote(when), sQuote(agenda_pathname))
      }
      pathname
    }
    
    files_apply(files, fun = source_print_eval,
                on_error = on_error, dryrun = dryrun, what = "Rprofile")
  }

  if (check) {
    # Check for unsafe changes to R options changes .Rprofile 
    check_options(debug = FALSE)
  }
  
  res <- api()
  if (unload) unload()
  invisible(res)
}

#' @export
rprofile <- function(...) .Defunct(new = "startup::rprofile_d()")
