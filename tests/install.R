message("*** install() / uninstall() ...")

print(startup:::is_installed())

path <- tempdir()

res <- startup:::is_installed(path = path)
print(res)
stopifnot(!isTRUE(res))

print(startup:::install(path = path))

res <- startup:::is_installed(path = path)
print(res)
stopifnot(isTRUE(res))

print(startup:::uninstall(path = path))

res <- startup:::is_installed(path = path)
print(res)
stopifnot(!isTRUE(res))

message("*** install() / uninstall() ... DONE")
