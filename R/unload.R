unload <- function(debug = FALSE) {
  if (debug) logf("- unloading the %s package", sQuote("startup"))
  unloadNamespace("startup")
}
