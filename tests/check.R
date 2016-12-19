message("*** Checks ...")

startup::check(fix = FALSE)
startup::check(all = TRUE, fix = FALSE)

startup:::check_rprofile_eof()
startup:::check_rprofile_eof(all = TRUE)

startup:::check_rprofile_update_packages()
startup:::check_rprofile_update_packages(all = TRUE)

startup:::check_rprofile_encoding()

message("*** Checks ... DONE")

