message("*** Checks ...")

startup::check(fix = FALSE)
startup::check(all = TRUE, fix = FALSE)

startup:::check_rprofile_eof()
startup:::check_rprofile_eof(all = TRUE)

startup:::check_rprofile_update_packages()
startup:::check_rprofile_update_packages(all = TRUE)

startup:::check_options()

oopts <- options(encoding = "C")
res <- tryCatch({
  startup:::check_options()
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

message("*** File name capitalization ...")

for (what in c("Renviron", "Rprofile")) {
  file <- sprintf(".%s", what)
  pathname <- file.path(tempdir(), file)
  cat("dummy", file = pathname)
  res <- startup:::warn_file_capitalization(pathname, what)
  stopifnot(isTRUE(res))
  file.remove(pathname)
  
  file <- toupper(file)
  pathname <- file.path(tempdir(), file)
  cat("dummy", file = pathname)
  res <- startup:::warn_file_capitalization(pathname, what)
  stopifnot(!isTRUE(res))

  res <- tryCatch({
    startup:::warn_file_capitalization(pathname, what)
  }, warning = identity)
  stopifnot(inherits(res, "warning"))
  file.remove(pathname)
}

message("*** File name capitalization ... DONE")

message("*** Checks ... DONE")
