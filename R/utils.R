stop_if_not <- function(...) {
  res <- list(...)
  n <- length(res)
  if (n == 0L) return()

  for (ii in 1L:n) {
    res_ii <- .subset2(res, ii)
    if (length(res_ii) != 1L || is.na(res_ii) || !res_ii) {
        mc <- match.call()
        call <- deparse(mc[[ii + 1]], width.cutoff = 60L)
        if (length(call) > 1L) call <- paste(call[1L], "...")
        stop(sQuote(call), " is not TRUE", call. = FALSE, domain = NA)
    }
  }
}

eof_ok <- function(file) {
  size <- file.info(file)$size
  ## On Windows, symbolic links give size = 0
  if (.Platform$OS.type == "windows" && size == 0L) size <- 1e9
  bfr <- readBin(file, what = "raw", n = size)
  n <- length(bfr)
  if (n == 0L) return(FALSE)
  is.element(bfr[n], charToRaw("\n\r"))
}

is_dir <- function(f) nzchar(f) && file.exists(f) && file.info(f)$isdir

is_file <- function(f) nzchar(f) && file.exists(f) && !file.info(f)$isdir

nlines <- function(f) {
  bfr <- readLines(f, warn = FALSE)
  bfr <- grep("^[ \t]*#", bfr, value = TRUE, invert = TRUE)
  bfr <- grep("^[ \t]*$", bfr, value = TRUE, invert = TRUE)
  length(bfr)
}

## base::file.size() was only introduced in R 3.2.0
file_size <- function(...) file.info(..., extra_cols = FALSE)$size

file_info <- function(f, type = "txt", normalize = FALSE, extra = NULL) {
  if (normalize) f <- normalizePath(f, mustWork = FALSE)
  if (!is.null(extra)) {
    extra <- paste0("; ", extra)
  } else {
    extra <- ""
  }
  if (type == "binary") {
    sprintf("%s (binary file; %d bytes%s)", sQuote(f), file_size(f), extra)
  } else if (type == "env") {
    sprintf("%s (%d lines; %d bytes%s)",
            sQuote(f), nlines(f), file_size(f), extra)
  } else if (type == "r") {
    sprintf("%s (%d code lines; %d bytes%s)",
            sQuote(f), nlines(f), file_size(f), extra)
  } else {
    sprintf("%s (%d lines; %d bytes%s)",
            sQuote(f), nlines(f), file_size(f), extra)
  }
}
