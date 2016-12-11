filter_files <- startup:::filter_files
sysinfo <- startup:::sysinfo()
sysinfo$os <- "linux"

message("*** filter_files() ...")

filesets <- list(
  A = c("a" = TRUE, "b" = TRUE, "package=<non-existing-package>" = FALSE, "package=startup" = TRUE),
  B = c("a,os=linux" = TRUE, "b,os=windows" = FALSE, "os=linux,os=osx" = FALSE, "package=startup,os=linux" = TRUE),
  C = c("a,os=linux" = TRUE, "b,os!=linux" = FALSE, "c,os!=windows" = TRUE),
  D = c("package!=startup" = FALSE, "package!=<non-existing-package>" = TRUE),
  E = c("os=linux,package!=startup" = FALSE, "os=linux,package!=<non-existing-package>" = TRUE),
  F = c("a" = TRUE, "/home/alice/.Rprofile.d/package=foo" = FALSE),
  G = c("a" = TRUE, "/home/alice/.Rprofile.d/package!=foo" = TRUE)
)

for (kk in seq_along(filesets)) {
  message(sprintf("File set #%d (%s) ...", kk, names(filesets)[kk]))
  
  files <- filesets[[kk]]
  files0 <- names(files)[files]
  files <- names(files)
  print(files)

  filesF <- filter_files(files, info = sysinfo)
  print(filesF)
  stopifnot(identical(filesF, files0))

  message(sprintf("File set #%d (%s) ... DONE", kk, names(filesets)[kk]))
}

message("*** filter_files() ... DONE")
