options(startup.dryrun = TRUE)

message("*** api() ...")

message("*** api()")
api <- startup:::api()
stopifnot(is.list(api), length(api) > 0)

message("*** renviron()")
res <- startup::renviron()
stopifnot(all.equal(res, api))

message("*** rprofile()")
res <- startup::rprofile()
stopifnot(all.equal(res, api))

res <- startup::rprofile(all = TRUE)

message("*** startup(unload = FALSE)")
res <- startup::startup(unload = FALSE)
stopifnot(all.equal(res, api))

message("*** startup()")
res <- startup::startup(debug = TRUE)
str(res)
stopifnot(all.equal(res, api))

options(startup.dryrun = FALSE)

message("*** api() ... DONE")

rm(list = c("api", "res"))
