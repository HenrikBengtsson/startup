message("*** find_files() ...")


pn <- startup:::find_rprofile()
print(pn)

pn <- startup:::find_rprofile(all = TRUE)
print(pn)

pn <- startup:::find_renviron()
print(pn)

pn <- startup:::find_renviron(all = TRUE)
print(pn)

pn <- startup:::find_rprofile_d()
print(pn)

pn <- startup:::find_rprofile_d(all = TRUE)
print(pn)

pn <- startup:::find_rprofile_d(sibling = TRUE, all = TRUE)
print(pn)

pn <- startup:::find_renviron_d()
print(pn)

pn <- startup:::find_renviron_d(all = TRUE)
print(pn)

pn <- startup:::find_renviron_d(sibling = TRUE, all = TRUE)
print(pn)

path <- system.file(package = "startup")
paths <- file.path(path, c(".Renviron.d", ".Rprofile.d"))
pn <- startup:::list_d_files(paths = paths)
print(pn)

message("*** find_files() ... DONE")
