api <- function() {
  list(
    renviron = renviron,
    rprofile = rprofile,
    unload   = function() unloadNamespace("startup")
  )
}
