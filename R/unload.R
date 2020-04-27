unload <- function(debug = FALSE) {
  if (debug) logf("- unloading the %s package", sQuote(.packageName))
  unloadNamespace(.packageName)
}
