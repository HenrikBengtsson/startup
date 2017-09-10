unload <- function(debug = FALSE) {
  unloadNamespace("startup")
}

api <- function() {
  list(
    renviron_d = renviron_d,
    rprofile_d = rprofile_d,
    unload     = unload
  )
}
