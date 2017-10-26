#' Restarts R
#'
#' Restarts R by quitting the current \R session and launching a new one.
#'
#' @param status An integer specifying the exit code of the current
#' \R session.
#' 
#' @param rcmd A character string specifying the command for launching \R.
#' The default is the same as used to launch the current \R session, i.e.
#' \code{\link[base:commandArgs]{commandArgs()[1]}}.
#'
#' @param args A character vector specifying zero or more command-line
#' arguments to be passed to the system call of \code{rcmd}.
#' If `NULL`, then \code{\link[base:commandArgs]{commandArgs()[-1]}} is used.
#' To not pass any arguments, use `args = character(0L)`.
#'
#' @param envvars A named character vector of environment variables to
#' be set when calling \R.  Alternatively, if not named the strings must
#' be of format `var=value`.
#'
#' @param as A character string specify a predefined set of `rcmd`, `args`,
#' and `envvars`.  If `as = "R CMD build"`, then the `R CMD build` environment
#' is emulated as far as possible.
#' 
#' @param debug If `TRUE`, debug messages are outputted, otherwise not.
#'
#' @examples
#' \dontrun{
#'   startup::restart(envvars = c(R_STARTUP_DEBUG = TRUE))
#'
#'   ## Mimic R CMD build
#'   startup::restart(as = "R CMD build")
#'
#'   ## ... which is short for
#'   startup::restart(args = c("--no-restore"),
#'                    envvars = c(R_DEFAULT_PACKAGES="", LC_COLLATE="C"))
#' }
#' 
#' @export
restart <- function(status = 0L, rcmd = NULL, args = NULL, envvars = NULL, as = NULL, debug = NA) {
  debug(debug)
  debug <- debug()
  if (debug) message("restart(): Customizing .Last() to relaunch R ...")

  cmdargs <- commandArgs()

  if (!is.null(as)) {
    stopifnot(length(as) == 1L, is.character(as))
    if (as == "R CMD build") {
      args <- c("--no-restore")
      envvars <- c(R_DEFAULT_PACKAGES = "", LC_COLLATE = "C")
    } else {
      stop("Unknown value on argument 'as': ", sQuote(as))
    }
  }
  
  if (is.null(rcmd)) rcmd <- cmdargs[1]
  stopifnot(length(rcmd) == 1L, is.character(rcmd))
  rcmd_t <- Sys.which(rcmd)
  if (rcmd_t == "") {
    stop("Argument 'rcmd' specify a non-existing command: ", sQuote(rcmd))
  }
    
  if (is.null(args)) args <- cmdargs[-1]
  stopifnot(is.character(args))
  
  if (!is.null(envvars) && length(envvars) > 0L) {
    names <- names(envvars)
    if (!is.null(names)) {
      envvars <- sprintf("%s=%s", names, shQuote(envvars))
    }
    stopifnot(is.character(envvars))
  }

  ## To please R CMD check
  envir <- globalenv()

  ## Make sure to call existing .Last(), iff any
  if (exists(".Last", envir = envir, inherits = FALSE)) {
    last_org <- get(".Last", envir = envir, inherits = FALSE)
  } else {
    last_org <- function() NULL
  }
  
  assign(".Last", function() {
    last_org()
    system2(rcmd, args = args, env = envvars)
  }, envir = envir)

  if (debug) message("restart(): Quitting current R session and starting a new one ...")
  
  quit(save = "no", status = status, runLast = TRUE)
}
