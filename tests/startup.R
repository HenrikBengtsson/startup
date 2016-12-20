renviron_d <- startup:::renviron_d
rprofile_d <- startup:::rprofile_d

message("*** startup() ...")

message("*** renviron_d() ...")

paths <- system.file(".Renviron.d", package = "startup")
files <- renviron_d(paths = paths)
print(files)

message("*** renviron_d() ... DONE")

message("*** rprofile_d() ...")

paths <- system.file(".Rprofile.d", package = "startup")
files <- rprofile_d(paths = paths)
print(files)

message("*** rprofile_d() ... DONE")

message("*** startup() ... DONE")
