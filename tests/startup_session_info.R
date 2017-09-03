message("*** startup_session_info() ...")

info_0 <- startup::startup_session_info()
utils::str(info_0)

info_1 <- startup::startup_session_info(reuse = TRUE, record = TRUE)
utils::str(info_1)
stopifnot(identical(info_1, info_0))

info_2 <- startup::startup_session_info(reuse = FALSE, record = FALSE)
utils::str(info_2)

info_3 <- startup::startup_session_info(reuse = FALSE, record = TRUE)
utils::str(info_3)

message("*** startup_session_info() ... DONE")
