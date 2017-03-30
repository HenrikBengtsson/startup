message("*** unload() ...")

loadNamespace("startup")
startup:::unload()
stopifnot(!"startup" %in% loadedNamespaces())

message("*** unload() ... DONE")
