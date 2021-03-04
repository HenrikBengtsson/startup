.onLoad <- function(libname, pkgname) {
  # Record session information as early as possible
  startup_session_options(action = "update")
  register_vignette_engine_during_build_only(pkgname)
}
