filter_files <- startup:::filter_files
sysinfo <- startup:::sysinfo()
sysinfo$os <- "linux"

message("*** filter_files() ...")

filesets <- list(
  A = c("a" = TRUE, "b" = TRUE, "package=<non-existing-package>" = FALSE, "package=startup" = TRUE),
  B = c("a,os=linux" = TRUE, "b,os=windows" = FALSE, "package=startup,os=linux" = TRUE)
)

for (kk in seq_along(filesets)) {
  files <- filesets[[kk]]
  files0 <- names(files)[files]
  files <- names(files)
  print(files)

  filesF <- filter_files(files, sysinfo = sysinfo)
  stopifnot(identical(filesF, files0))
}

message("*** filter_files() ... DONE")
