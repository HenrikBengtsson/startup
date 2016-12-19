unload <- function(debug = FALSE) unloadNamespace("startup")

api <- function() {
  list(
    renviron   = renviron,     ## Deprecated
    rprofile   = rprofile,     ## Deprecated
    renviron_d = renviron_d,
    rprofile_d = rprofile_d,
    unload     = unload
  )
}
