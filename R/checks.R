check_rprofile <- function() {
  # (iii) Check for common mistakes?
  if (!isTRUE(getOption(".Rprofile.check", TRUE))) return()
  
  if (isTRUE(getOption(".Rprofile.check.encoding", TRUE) && !interactive() && getOption("encoding", "native.enc") != "native.enc")) {
    msg <- sprintf("POTENTIAL STARTUP PROBLEM: Option 'encoding' seems to have been set (to '%s') during startup, cf. Startup.  Changing this from the default 'native.enc' is known to have caused problems, particularly in non-interactive sessions, e.g. installation of packages with non-ASCII characters (also in source code comments) fails. To disable this warning, set option '.Rprofile.check.encoding' to FALSE, or set the encoding conditionally, e.g. if (base::interactive()) options(encoding='UTF-8').",  getOption("encoding"))
    warning(msg)
  }
}
