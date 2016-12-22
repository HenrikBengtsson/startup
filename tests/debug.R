message("*** debug() ...")

debug <- startup:::debug

print(debug())

print(debug(TRUE))
stopifnot(debug())

startup:::log("Hello")
startup:::logf("Hello %s", "world")
startup:::logp(str(1:10))

print(debug(FALSE))
stopifnot(!debug())

message("*** debug() ... DONE")

rm(list = "debug")
