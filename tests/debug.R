message("*** debug() ...")

debug <- startup:::debug ## non-exported
is_debug_on <- startup::is_debug_on

print(debug())
print(is_debug_on())

print(debug(TRUE))
stopifnot(is_debug_on())

startup:::log("Hello")
startup:::logf("Hello %s", "world")
startup:::logp(str(1:10))

print(debug(FALSE))
stopifnot(!is_debug_on())

message("*** debug() ... DONE")

rm(list = "debug")
