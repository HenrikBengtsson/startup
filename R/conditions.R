#' Produce a warning
#'
#' @param ...,domain The message and optionally the domain used for
#' translation.  The \ldots arguments are passed to [base::sprintf] to
#' create the message string.
#'
#' @param call. If [base::TRUE], the call is included in the warning
#' message, otherwise not.
#'
#' @param immediate. If [base::TRUE], the warning is outputted immediately,
#' otherwise not.
#'
#' @export
warn <- function(..., call. = FALSE, immediate. = TRUE, domain = NULL) {
  msg <- .makeMessage(sprintf(...), domain = domain)
  files <- unlist(find_source_traceback(), use.names = FALSE)
  if (length(files) > 0) {
    files <- paste(squote(files), collapse = "->")
    msg <- sprintf("%s: %s", files, msg)
  }
 # calls <- sys.calls()
 # utils::str(calls)
  warning(msg, call. = call., immediate. = immediate., domain = NULL)
}
