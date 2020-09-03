unload <- function(debug = FALSE) {
  if (debug) logf("- unloading the %s package", squote(.packageName))
  unloadNamespace(.packageName)
}
