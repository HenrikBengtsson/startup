filter_files <- startup:::filter_files
sysinfo <- startup:::sysinfo()
sysinfo$os <- "linux"
sysinfo$rstudio <- TRUE
sysinfo$wine <- FALSE
sysinfo$interactive <- FALSE
Sys.setenv(FOO = "abc")
Sys.setenv(BAR = "123")
Sys.unsetenv("UNKNOWN")

message("*** filter_files() ...")

filesets <- list(
  A = c("a" = TRUE, "b" = TRUE, "package=<non-existing-package>" = FALSE,
        "package=startup" = TRUE),
  B = c("a,os=linux" = TRUE, "b,os=windows" = FALSE, "os=linux,os=osx" = FALSE,
        "package=startup,os=linux" = TRUE),
  C = c("a,os=linux" = TRUE, "b,os!=linux" = FALSE, "c,os!=windows" = TRUE),
  D = c("package!=startup" = FALSE, "package!=<non-existing-package>" = TRUE),
  E = c("os=linux,package!=startup" = FALSE,
        "os=linux,package!=<non-existing-package>" = TRUE),
  F = c("a" = TRUE, "/home/alice/.Rprofile.d/package=foo" = FALSE),
  G = c("a" = TRUE, "/home/alice/.Rprofile.d/package!=foo" = TRUE),
  H = c("/home/alice/.Rprofile.d/rstudio=T/wine=0" = TRUE),
  I = c("/home/alice/.Rprofile.d/rstudio!=f/wine!=1" = TRUE),
  J = c("/home/alice/.Rprofile.d/interactive=TRUE" = FALSE,
        "/home/alice/.Rprofile.d/interactive=FALSE" = TRUE),
  K = c("/home/alice/.Rprofile.d/interactive=TRUE/package=fortunes" = FALSE),
  L = c("/home/alice/.Rprofile.d/package=startup,package=base" = TRUE),
  M = c("/home/alice/.Rprofile.d/package=startup,package!=base" = FALSE),
  N = c("/home/alice/.Rprofile.d/FOO=abc,BAR=123" = TRUE),
  O = c("/home/alice/.Rprofile.d/FOO=abc,BAR!=321" = TRUE),
  P = c("/home/alice/.Rprofile.d/FOO=abc,BAR!=123" = FALSE),
  Q = c("/home/alice/.Rprofile.d/FOO=abc/BAR=123/help" = TRUE),
  R = c("/home/alice/.Rprofile.d/UNKNOWN=42/test" = FALSE),
  S = c("/home/alice/.Rprofile.d/UNKNOWN!=42/test" = TRUE)
)

## Test with filename extensions *.R as well
filesets2 <- lapply(filesets, FUN = function(f) {
  names(f) <- sprintf("%s.R", names(f))
  f
})
names(filesets2) <- sprintf("%s.R", names(filesets))
#filesets <- c(filesets, filesets2)


for (kk in seq_along(filesets)) {
  message(sprintf("File set #%d (%s) ...", kk, names(filesets)[kk]))

  files <- filesets[[kk]]
  files_truth <- names(files)[files]
  files <- names(files)
  cat("Before:\n")
  print(files)

  files_filtered <- filter_files(files, info = sysinfo)
  cat("After:\n")
  print(files_filtered)
  cat("Expected:\n")
  print(files_truth)
  
  stopifnot(all.equal(files_filtered, files_truth, check.attributes = FALSE))

  message(sprintf("File set #%d (%s) ... DONE", kk, names(filesets)[kk]))
}

message("*** filter_files() ... DONE")
