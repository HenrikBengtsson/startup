## Checks if running R via Rscript or not
##
## _WARNING: This function does not work - it always returns FALSE \[1\]._
##
## @return A logical
##
## @details
## This functions use `basename(commandArgs()[1])` to infer whether or not
## \R was launched via \file{Rscript}.  On Windows, both \file{Rscript} and
## \file{Rscript.exe} are recognized and the check is case insensitive.
##
## @references
## 1. <https://github.com/HenrikBengtsson/startup/issues/97>
is_rscript <- local({
  result <- NA
  
  function() {
    if (is.na(result)) {
      cmd_args <- getOption("startup.commandArgs", commandArgs())
      executable <- basename(cmd_args[1])
      if (.Platform$OS.type != "windows") {
        result <<- (executable == "Rscript")
      } else {
        result <<- (tolower(executable) %in% c("rscript", "rscript.exe"))
      }
    }
    result
  }
})

