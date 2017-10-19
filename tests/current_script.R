message("*** current_script() ...")

res <- startup::current_script()
print(res)
stopifnot(is.character(res), length(res) == 1L, is.na(res))

startup:::current_script_pathname("foo")
res <- startup::current_script()
print(res)
stopifnot(is.character(res), length(res) == 1L, res == "foo")

startup:::current_script_pathname(NA_character_)
res <- startup::current_script()
print(res)
stopifnot(is.character(res), length(res) == 1L, is.na(res))

message("*** current_script() ... DONE")
