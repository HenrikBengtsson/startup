message("*** install() / uninstall() ...")

print(startup:::is_installed())

path <- tempdir()


message("- install() ...")

file <- file.path(path, ".Rprofile")
res <- startup:::is_installed(file)
print(res)
stopifnot(!res)

print(startup:::install(path = path))
res <- startup:::is_installed(file)
print(res)
stopifnot(res)

res <- tryCatch({
  startup:::install(path = path, backup = FALSE)
}, warning = identity)
print(res)
stopifnot(inherits(res, "warning"))

cat("# Empty\n", file = file)
print(startup:::install(path = path, backup = FALSE))
res <- startup:::is_installed(file)
print(res)
stopifnot(res)


message("- uninstall() ...")

print(startup:::uninstall(path = path))

res <- startup:::is_installed(file)
print(res)
stopifnot(!res)

res <- tryCatch({
  startup:::uninstall(path = path)
}, warning = identity)
print(res)
stopifnot(inherits(res, "warning"))

message("*** install() / uninstall() ... DONE")
