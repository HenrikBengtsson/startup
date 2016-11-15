options(startup.dryrun = TRUE)

api <- startup:::api()
stopifnot(is.list(api), length(api) > 0)

res <- startup::renviron()
stopifnot(all.equal(res, api))

res <- startup::rprofile()
stopifnot(all.equal(res, api))

res <- startup::everything()
stopifnot(all.equal(res, api))

options(startup.dryrun = FALSE)

rm(list = c("api", "res"))

