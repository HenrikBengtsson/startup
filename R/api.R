unload <- function(debug = FALSE) unloadNamespace("startup")

api <- function() {
  list(
    renviron = renviron,
    rprofile = rprofile,
    unload   = unload
  )
}
