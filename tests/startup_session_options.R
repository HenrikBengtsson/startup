message("*** startup_session_options() ...")

opts_0 <- startup::startup_session_options()
utils::str(opts_0)

opts_1 <- startup::startup_session_options(action = "update")
utils::str(opts_1)
stopifnot(identical(opts_1, opts_0))

opts_2 <- startup::startup_session_options(action = "overwrite")
utils::str(opts_2)

opts_3 <- startup::startup_session_options(action = "erase")
utils::str(opts_3)
stopifnot(all(unlist(lapply(opts_3, FUN = is.null))))

opts_4 <- startup::startup_session_options()
utils::str(opts_4)

message("*** startup_session_options() ... DONE")
