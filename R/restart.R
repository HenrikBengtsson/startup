#' Restarts R
#'
#' Restarts \R by quitting the current \R session and launching a new one.
#'
#' @param status An integer specifying the exit code of the current
#' \R session.
#' 
#' @param workdir The working directory where the new \R session should
#' be launched from.  If `NULL`, then the working directory that was in
#' place when the \pkg{startup} package was first loaded.  If using
#' `startup::startup()` in an \file{.Rprofile} startup file, then this
#' is likely to record the directory from which \R itself was launched from.
#' 
#' @param rcmd A character string specifying the command for launching \R.
#' The default is the same as used to launch the current \R session, i.e.
#' \code{\link[base:commandArgs]{commandArgs()[1]}}.
#'
#' @param args A character vector specifying zero or more command-line
#' arguments to be appended to the system call of \code{rcmd}.
#'
#' @param envvars A named character vector of environment variables to
#' be set when calling \R.
#'
#' @param as A character string specifying a predefined setups of `rcmd`,
#' `args`, and `envvars`.  For details, see below.
#' 
#' @param debug If `TRUE`, debug messages are outputted, otherwise not.
#'
#' @section Predefined setups:
#' Argument `as` may take the following values:
#' \describe{
#'  \item{\code{"current"}:}{(Default) A setup that emulates the setup of the
#'   current \R session as far as possible by relaunching \R with the same
#'   command-line call (= [base::commandArgs()]).
#'  }
#'  \item{\code{"specified"}:}{According to `rcmd`, `args`, and `envvars`.}
#'  \item{\code{"R CMD build"}:}{A setup that emulates
#'   [`R CMD build`](https://github.com/wch/r-source/blob/R-3-4-branch/src/scripts/build)
#'   as far as possible.
#'  }
#'  \item{\code{"R CMD check"}:}{A setup that emulates
#'   [`R CMD check`](https://github.com/wch/r-source/blob/R-3-4-branch/src/scripts/check)
#'   as far as possible, which happens to be identical to the
#'  `"R CMD build"` setup.
#'  }
#'  \item{\code{"R CMD INSTALL"}:}{A setup that emulates
#'   [`R CMD INSTALL`](https://github.com/wch/r-source/blob/R-3-4-branch/src/scripts/INSTALL)
#'   as far as possible.
#'  }
#' }
#' If specified, command-line arguments in `args` and environment variables
#' in `envvars` are _appended_ accordingly.
#'
#' @section Known limitations:
#' It is _not_ possible to restart an \R session in RStudio using this
#' function.
#' Note, RStudio provides `.rs.restartR()` which will indeed restart the
#' current \R session. However, it does not let you control how \R is
#' restarted, e.g. with what command-line options and what environment
#' variables.  Furthermore, the new \R session will have the same set of
#' packages loaded as before, the same variables in the global environment,
#' and so on.
#'
#' @examples
#' \dontrun{
#'   ## Relaunch R with debugging of startup::startup() enabled
#'   startup::restart(envvars = c(R_STARTUP_DEBUG = TRUE))
#'
#'   ## Relaunch R without loading user Rprofile files
#'   startup::restart(args = "--no-init-file")
#'
#'   ## Mimic 'R CMD build' and 'R CMD check'
#'   startup::restart(as = "R CMD build")
#'   startup::restart(as = "R CMD check")
#'   ## ... which are both short for
#'   startup::restart(args = c("--no-restore"),
#'                    envvars = c(R_DEFAULT_PACKAGES="", LC_COLLATE="C"))
#' }
#'
#' @export
restart <- function(status = 0L,
                    workdir = NULL,
                    rcmd = NULL, args = NULL, envvars = NULL,
                    as = c("current", "specified",
                           "R CMD build", "R CMD check", "R CMD INSTALL"),
                    debug = NA) {
  debug(debug)
  logf("Restarting R ...")

  ## The RStudio Console cannot be restart this way
  if (is_rstudio_console()) {
    stop("R sessions run via the RStudio Console cannot be restarted using startup::restart(). It is possible to restart R in an RStudio Terminal. To restart an R session in the RStudio Console, use rstudioapi::restartSession().")
  }

  if (is.null(workdir)) {
    workdir <- startup_session_options()$startup.session.startdir
  }
  if (!is_dir(workdir)) {
    stop("Argument 'workdir' specifies a non-existing directory: ",
         sQuote(workdir))
  }
  
  cmdargs <- commandArgs()

  if (is.null(rcmd)) rcmd <- cmdargs[1]
  stopifnot(length(rcmd) == 1L, is.character(rcmd))
  rcmd_t <- Sys.which(rcmd)
  if (rcmd_t == "") {
    stop("Argument 'rcmd' specifies a non-existing command: ", sQuote(rcmd))
  }
 
  as <- match.arg(as)
  if (as == "specified") {
  } else if (as == "current") {
    if (is.null(args)) args <- cmdargs[-1]
  } else if (as %in% c("R CMD build", "R CMD check")) {
    args <- c("--no-restore", args)
    envvars <- c(R_DEFAULT_PACKAGES = "", LC_COLLATE = "C", envvars)
  } else if (as %in% c("R CMD INSTALL")) {
    vanilla_install <- nzchar(Sys.getenv("R_INSTALL_VANILLA"))
    if (vanilla_install) {
      args <- c("--vanilla", args)
    } else {
      args <- c("--no-restore", args)
    }
    envvars <- c(R_DEFAULT_PACKAGES = "", LC_COLLATE = "C", envvars)
  } else {
    stop("Unknown value on argument 'as': ", sQuote(as))
  }
  
  if (!is.null(envvars) && length(envvars) > 0L) {
    stopifnot(!is.null(names(envvars)))
    envvars <- sprintf("%s=%s", names(envvars), shQuote(envvars))
  }

  ## To please R CMD check
  envir <- globalenv()

  ## Make sure to call existing .Last(), iff any
  has_last <- exists(".Last", envir = envir, inherits = FALSE)
  if (has_last) {
    last_org <- get(".Last", envir = envir, inherits = FALSE)
  } else {
    last_org <- function() NULL
  }

  logf("- R executable: %s", rcmd)
  logf("- Command-line arguments: %s", paste(args, collapse = " "))
  logf("- Environment variables: %s", paste(envvars, collapse = " "))
  
  assign(".Last", function() {
    last_org()
    system2(rcmd, args = args, env = envvars)
  }, envir = envir)

  logf("- quitting current R session")
  if (has_last) logf("- existing .Last() will be acknowledged")
  logf("Restarting R ... done")

  setwd(workdir)
  quit(save = "no", status = status, runLast = TRUE)
}
