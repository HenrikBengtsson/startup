message("*** Checks ...")

startup::check(fix = FALSE)
startup::check(all = TRUE, fix = FALSE)

startup:::check_rprofile_eof()
startup:::check_rprofile_eof(all = TRUE)

startup:::check_rprofile_update_packages()
startup:::check_rprofile_update_packages(all = TRUE)

startup:::check_rprofile_encoding()

message("*** Checks - test files ...")

paths <- system.file(".Rprofile.d", package = "startup")
files <- startup:::list_d_files(paths)
startup:::check_rprofile_eof(files = files)
startup:::check_rprofile_update_packages(files = files)
oopts <- options(encoding = "C")
startup:::check_rprofile_encoding()
options(oopts)

message("*** Checks - test files ... DONE")

message("*** Checks ... DONE")

