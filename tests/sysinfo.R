message("*** sysinfo() ...")

message("- Base R system information:")

utils::str(list(
  "capabilities()"     = capabilities(),
  .Machine             = .Machine,
  .Platform            = .Platform,
  R.version            = R.version,
  "Sys.info()"         = as.list(Sys.info())
))

message("- Session information:")
print(utils::sessionInfo())


message("- sysinfo():")
print(startup::sysinfo())


message("*** sysinfo() ... DONE")
