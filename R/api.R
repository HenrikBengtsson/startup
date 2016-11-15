api <- function() {
  list(
    renviron = renviron,
    rprofile = rprofile,
    unload   = function(debug = FALSE) unloadNamespace("startup")
  )
}
