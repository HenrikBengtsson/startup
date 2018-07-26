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
