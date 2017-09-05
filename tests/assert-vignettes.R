## Because of the .onLoad() hack, it could be that one day R is
## updated such that the package vignettes are not build.  If so,
## we try to detect it here.

message("*** Assert that package vignettes exist ...")
message(paste(loadedNamespaces(), sep = "\n"))
message(paste(Sys.getenv(), sep = "\n"))

## WORKAROUND: On AppVeyor CI, vignettes are dropped / not built,
## and when running covr, R_CMD is not used.
if (getRversion() >= "3.0.0" &&
    length(packageDescription("startup")$VignetteBuilder) &&
    Sys.getenv("R_COVR") == "") {
  vigns <- utils::vignette(package = "startup")
  print(vigns)
  str(vigns)
  stopifnot(nrow(vigns$results) > 0)
}

## Test vignette engine registration
ovalue <- Sys.getenv("R_CMD")
Sys.setenv("R_CMD" = "dummy")
startup:::register_vignette_engine_during_build_only("startup")
Sys.setenv("R_CMD" = ovalue)

message("*** Assert that package vignettes exist ... DONE")
