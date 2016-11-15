debug <- startup:::debug

print(debug())
print(debug(TRUE))
stopifnot(debug())
print(debug(FALSE))
stopifnot(!debug())

rm(list = "debug")
