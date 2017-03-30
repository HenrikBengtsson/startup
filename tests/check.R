message("*** Checks ...")

startup::check(fix = FALSE)
startup::check(all = TRUE, fix = FALSE)

startup:::check_rprofile_eof()
startup:::check_rprofile_eof(all = TRUE)

startup:::check_rprofile_update_packages()
startup:::check_rprofile_update_packages(all = TRUE)

startup:::check_rprofile_encoding()

oopts <- options(encoding = "C")
res <- tryCatch({
  startup:::check_rprofile_encoding()
}, warning = identity)
if (!interactive()) stopifnot(inherits(res, "simpleWarning"))
options(oopts)

message("*** Checks - test files ...")

path <- system.file("Rprofile.d,checks", package = "startup")
path_tmp <- tempdir()
file.copy(path, path_tmp, recursive = TRUE, overwrite = TRUE)

files <- startup:::list_d_files(path_tmp)
print(files)

res <- tryCatch({
  startup:::check_rprofile_eof(files = files, fix = FALSE)
}, error = identity)
stopifnot(inherits(res, "simpleError"))

res <- tryCatch({
  startup:::check_rprofile_eof(files = files)
}, warning = identity)
stopifnot(inherits(res, "simpleWarning"))

res <- tryCatch({
  startup:::check_rprofile_update_packages(files = files)
}, error = identity)
stopifnot(inherits(res, "simpleError"))


message("*** Checks - test files ... DONE")

message("*** Checks ... DONE")
