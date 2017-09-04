## Because of the .onLoad() hack, it could be that one day R is
## updated such that the package vignettes are not build.  If so,
## we try to detect it here.

message("*** Assert that package vignettes exist ...")

## WORKAROUND: On AppVeyor CI, vignettes are dropped / not built
if (length(packageDescription("startup")$VignetteBuilder) > 0) {
  vigns <- utils::vignette(package = "startup")
  print(vigns)
  str(vigns)
  stopifnot(nrow(vigns$results) > 0)
}

message("*** Assert that package vignettes exist ... DONE")
