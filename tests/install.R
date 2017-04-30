message("*** install() / uninstall() ...")

print(startup:::is_installed())

path <- tempdir()

file <- file.path(path, ".Rprofile")
res <- startup:::is_installed(file)
print(res)
stopifnot(!res)

print(startup:::install(path = path))

res <- startup:::is_installed(file)
print(res)
stopifnot(res)

print(startup:::uninstall(path = path))

res <- startup:::is_installed(file)
print(res)
stopifnot(!res)

message("*** install() / uninstall() ... DONE")
