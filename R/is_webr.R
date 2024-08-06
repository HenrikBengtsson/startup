#' Checks if running R via webR
#'
#' @return A logical
#'
#' @references
#' 1. webR - R in the Browser, <https://docs.r-wasm.org/webr/latest/>
is_webr <- function() {
  if (!"webr" %in% loadedNamespaces()) return(FALSE)

  ## Source: https://github.com/r-wasm/webr/issues/414
  ## In webr (> 0.3.2) [2024-04-23]
  if (Sys.getenv("WEBR") == "1") return(TRUE)

  ## Fallback: https://github.com/r-wasm/webr/issues/414
  ns <- getNamespace("webr")
  if (!exists("eval_js", mode = "function", envir = ns)) return(FALSE)
  eval_js <- get("eval_js", mode = "function", envir = ns)
  eval_js("'webr' in Module") == 1L
}
