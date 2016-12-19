message("*** backup() ...")

pn <- tempfile()
cat("Hello", file = pn)
stopifnot(file.exists(pn))
pnB <- startup:::backup(pn)
print(pnB)
stopifnot(file.exists(pn), file.exists(pnB))

message("*** backup() ... DONE")
