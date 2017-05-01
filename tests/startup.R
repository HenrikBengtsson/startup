renviron <- startup:::renviron
rprofile <- startup:::rprofile
renviron_d <- startup:::renviron_d
rprofile_d <- startup:::rprofile_d

message("*** startup() ...")

message("*** renviron_d() ...")

paths <- system.file(".Renviron.d", package = "startup")
print(paths)
api <- renviron_d(paths = paths, skip = FALSE)
str(api)
renviron_d(paths = paths, skip = FALSE, dryrun = TRUE)

message("*** renviron_d() ... DONE")

message("*** rprofile_d() ...")

paths <- system.file(".Rprofile.d", package = "startup")
print(paths)
api <- rprofile_d(paths = paths, skip = FALSE)
str(api)
rprofile_d(paths = paths, skip = FALSE, dryrun = TRUE)

message("*** rprofile_d() ... DONE")


message("*** startup() - deprecated ...")

paths <- system.file(".Renviron.d", package = "startup")
res <- tryCatch(renviron(paths = paths, skip = FALSE), warning = identity)
stopifnot(inherits(res, "simpleWarning"))
renviron(paths = paths, skip = FALSE, dryrun = TRUE)

paths <- system.file(".Rprofile.d", package = "startup")
res <- tryCatch(rprofile(paths = paths, skip = FALSE), warning = identity)
stopifnot(inherits(res, "simpleWarning"))
rprofile(paths = paths, skip = FALSE, dryrun = TRUE)

message("*** startup() - deprecated ... DONE")


message("*** startup() - exceptions ...")

path <- system.file("Rprofile.d,checks", package = "startup")
path_tmp <- tempdir()
file.copy(path, path_tmp, recursive = TRUE, overwrite = TRUE)

oopts <- options(encoding = "native.enc")
res <- tryCatch({
  rprofile_d(paths = path_tmp, skip = FALSE, on_error = "warning")
}, warning = identity)
stopifnot(inherits(res, "simpleWarning"))

options(encoding = "native.enc")
res <- tryCatch({
  rprofile_d(paths = path_tmp, skip = FALSE, on_error = "immediate.warning")
}, warning = identity)
stopifnot(inherits(res, "simpleWarning"))

options(encoding = "native.enc")
res <- tryCatch({
  rprofile_d(paths = path_tmp, skip = FALSE, on_error = "error")
}, error = identity)
stopifnot(inherits(res, "simpleError"))

options(encoding = "native.enc")
res <- rprofile_d(paths = path_tmp, skip = FALSE, on_error = "message")
stopifnot(is.list(res))

options(encoding = "native.enc")
res <- rprofile_d(paths = path_tmp, skip = FALSE, on_error = "ignore")
stopifnot(is.list(res))

options(oopts)

message("*** startup() - exceptions ... DONE")


message("*** startup() ... DONE")
