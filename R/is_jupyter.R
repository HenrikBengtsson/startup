#' Checks if running R via Jupyter
#'
#' @return A logical
is_jupyter <- function() {
  args <- commandArgs()
  idx <- match("--args", args)
  if (!is.na(idx)) args <- args[seq_len(idx - 1)]
  any(grepl("IRkernel::main()", args))
}
