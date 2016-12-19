#' Check for and fix common mistakes in .Rprofile
#'
#' Check for and fix common mistakes in \file{.Rprofile} files.
#;
#' @param all Should all or only the first entry on \link[base:Startup]{the R startup search path} be checked?
#' @param fix If \code{TRUE}, detected issues will be tried to be automatically fixed, otherwise not.
#' @param backup If \code{TRUE}, a timestamped backup copy of the original file is created before modifying it, otherwise not.
#' @param debug If \code{TRUE}, debug messages are outputted, otherwise not.
#'
#' @references
#' \itemize{
#'   \item R-devel thread \emph{Last line in .Rprofile must have newline (PR#4056)}, 2003-09-03, \url{https://stat.ethz.ch/pipermail/r-devel/2003-September/027457.html}
#' }
#'
#' @export
check <- function(all = FALSE, fix = TRUE, backup = TRUE, debug = FALSE) {
  check_rprofile_eof(all = all, fix = fix, backup = backup, debug = debug)
  check_rprofile_update_packages(all = all, debug = debug)
}


check_rprofile_eof <- function(all = FALSE, fix = TRUE, backup = TRUE, debug = FALSE) {
  eof_ok <- function(file) {
    size <- file.info(file)$size
    bfr <- readBin(file, what = "raw", n = size)
    is.element(bfr[size], charToRaw("\n\r"))
  }

  debug(debug)
  files <- find_rprofile(all = all)

  for (kk in seq_along(files)) {
    file <- files[kk]
    if (!eof_ok(file)) {
      if (fix) {
        if (backup) backup(file)
        ## Try to fix it by appending a newline
        try(cat(file = file, "\n", append = TRUE))
        if (eof_ok(file)) {
          msg <- sprintf("SYNTAX ISSUE FIXED: Added missing newline to the end of file %s, which otherwise would cause R to silently ignore the file in the startup process.", file)
          warning(msg)
        } else {
          msg <- sprintf("SYNTAX ERROR: Tried to add missing newline to the end of file %s, which otherwise would cause R to silently ignore the file in the startup process, but failed.", file)
          stop(msg)
        }
      } else {
        msg <- sprintf("SYNTAX ERROR: File %s is missing a newline at the end of the file, which most likely will cause R to silently ignore the file in the startup process.", file)
        stop(msg)
      }
    }
  }
}


check_rprofile_update_packages <- function(all = FALSE, debug = FALSE) {
  files <- find_rprofile(all = all)
  paths <- find_rprofile_d(all = all)
  files <- c(files, list_d_files(paths))
  if (length(files) == 0) return()
  for (file in files) {
    bfr <- readLines(file, warn = FALSE)
    bfr <- gsub("#.*", "", bfr, fixed = FALSE)
    pattern <- "update.packages[(][^)]*[)]"
    if (any(grepl(pattern, bfr, fixed = FALSE))) {
      msg <- sprintf("UNSAFE STARTUP CALL DETECTED: Calling update.packages() during R startup risks recursively spawning of an infinite number of R processes. Please remove offending call in order for .Rprofile scripts to be applied: %s", file)
      stop(msg)
    }
  }
  invisible()
}




check_rprofile_encoding <- function(debug = FALSE) {
  if (isTRUE(getOption(".Rprofile.check.encoding", TRUE) && !interactive() && getOption("encoding", "native.enc") != "native.enc")) {
    msg <- sprintf("POTENTIAL STARTUP PROBLEM: Option 'encoding' seems to have been set (to '%s') during startup, cf. Startup.  Changing this from the default 'native.enc' is known to have caused problems, particularly in non-interactive sessions, e.g. installation of packages with non-ASCII characters (also in source code comments) fails. To disable this warning, set option '.Rprofile.check.encoding' to FALSE, or set the encoding conditionally, e.g. if (base::interactive()) options(encoding='UTF-8').",  getOption("encoding"))
    warning(msg)
  }
}
