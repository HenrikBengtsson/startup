message("*** backup() ...")

pathname <- tempfile()
cat("Hello", file = pathname)
stopifnot(file.exists(pathname))
pathname_backup <- startup:::backup(pathname)
print(pathname_backup)
stopifnot(file.exists(pathname), file.exists(pathname_backup))

message("*** backup() ... DONE")
