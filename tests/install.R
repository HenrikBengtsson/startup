message("*** install() / uninstall() ...")

print(startup:::is_installed())

path <- tempdir()


message("- install() ...")

file <- file.path(path, ".Rprofile")
res <- startup:::is_installed(file)
print(res)
stopifnot(!res)

print(startup:::install(file))
res <- startup:::is_installed(file)
print(res)
stopifnot(res)

res <- tryCatch({
  startup:::install(file, backup = FALSE)
}, warning = identity)
print(res)
stopifnot(inherits(res, "warning"))

cat("# Empty\n", file = file)
print(startup:::install(file, backup = FALSE))
res <- startup:::is_installed(file)
print(res)
stopifnot(res)


message("- uninstall() ...")

print(startup:::uninstall(file))

res <- startup:::is_installed(file)
print(res)
stopifnot(!res)

res <- tryCatch({
  startup:::uninstall(file)
}, warning = identity)
print(res)
stopifnot(inherits(res, "warning"))

message("*** install() / uninstall() ... DONE")
