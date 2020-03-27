#' Options and environment variables used by the 'startup' package
#'
#' Below are environment variables and \R options that are used by the
#' \pkg{startup} package.\cr
#'
#' @section Controls whether \pkg{startup} is used or not:
#'
#' \describe{
#'   \item{\env{R_STARTUP_DISABLE} / \option{startup.disable}:}{
#'     (logical)
#'     If `TRUE`, `startup::startup()` is fully disable such that _no_
#'     \file{.Renviron.d/} or \file{.Rprofile.d/} files are processed.
#'     _Note_: Files \file{.Renviron} and \file{.Rprofile} are still processed
#'     because these are out of control of the \pkg{startup} package.
#'     (Default: `FALSE`)
#'   }
#'
#'   \item{\env{R_STARTUP_DRYRUN} / \option{startup.dryrun}:}{
#'     (logical)
#'     Controls the default value of argument `dryrun` of [startup()].
#'     (Default: `FALSE`)
#'   }
#' }
#'
#'
#' @section Additional customization of the startup process:
#'
#' \describe{
#'   \item{\env{R_STARTUP_INIT} / \option{startup.init}:}{
#'     (R code as a character string)
#'     Optional \R code that is parsed and evaluated after \file{.Renviron.d/}
#'     and \file{.Rprofile.d/} files have been processed, e.g.
#'     `R_STARTUP_INIT="message('Hello world')" R --quiet`.
#'     The specified string must be parsable by [base::parse()].
#'     (Default: not specified)
#'   }
#'
#'   \item{\env{R_STARTUP_RDATA} / \option{startup.rdata}:}{
#'     (comma-separated values)
#'     Controls whether an existing \file{./.RData} file should be processed 
#'     or not.
#'     If `"remove"`, it will be skipped by automatically removing it.
#'     If `"rename"`, it will be renamed to \file{./.RData.YYYYMMDD_hhmmss}
#'     where the timestamp is the last time the file was modified.
#'     If `"prompt"`, the user is prompted whether they want to load the file
#'     or rename it. In non-interactive session, `"prompt"` will fallback to 
#'     loading the content (default). To fallback to renaming the file, use
#'     `"prompt,rename"`.
#'     (Default: not specified)
#'   }
#' }
#'
#'
#' @section Controls what validation checks are performed at startup:
#'
#' \describe{
#'   \item{\env{R_STARTUP_CHECK} / \option{startup.check}:}{
#'     (logical)
#'     Controls the default value of argument `check` of [startup()].
#'     (Default: `TRUE`)
#'   }
#'
#'   \item{\option{startup.check.options.ignore}:}{
#'     (character vector)
#'     Names of \R options that should _not_ be validated at the end of the
#'     [startup()] process.
#'     (Default: `NULL`)
#'   }
#' }
#'
#'
#' @section Settings useful for debugging and prototyping:
#'
#' \describe{
#'
#'   \item{\env{R_STARTUP_DEBUG} / \option{startup.debug}:}{
#'     (logical)
#'     Controls the default value of argument `debug` of [startup()].
#'     (Default: `FALSE`)
#'   }
#'
#'   \item{\option{startup.debug.commandArgs}:}{
#'     (character vector)
#'     Overrides the command-line arguments that [startup()] uses, which
#'     can be useful to prototype and test alternative ways that \R might
#'     be launched.
#'     (Default: `base::commandArgs()`)
#'   }
#'
#'   \item{\env{R_STARTUP_TIME}:}{
#'     (POSIX timestamp; character string)
#'     Overrides the current timestamp, which can be useful to prototype and
#'     test functionalities that depend on the current time, e.g. inclusion
#'     and exclusion of files based on `when=<periodicity>` tags.
#'     The specified string must be parsable by [base::as.POSIXct()].
#'     (Default: not specified)
#'   }
#' }
#'
#'
#' @aliases
#' startup.check
#' startup.check.options.ignore
#' startup.debug
#' startup.debug.commandArgs
#' startup.dryrun
#' R_STARTUP_CHECK
#' R_STARTUP_DISABLE
#' R_STARTUP_DRYRUN
#' R_STARTUP_INIT
#' R_STARTUP_RDATA
#' R_STARTUP_TIME
#'
#' @name startup.options
NULL
