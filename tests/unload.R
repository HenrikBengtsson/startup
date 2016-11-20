loadNamespace("startup")
startup:::unload()
stopifnot(!"startup" %in% loadedNamespaces())

