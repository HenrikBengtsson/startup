# Restarts R

Restarts R by quitting the current R session and launching a new one.

## Usage

``` r
restart(
  status = 0L,
  workdir = NULL,
  rcmd = NULL,
  args = NULL,
  envvars = NULL,
  as = c("current", "specified", "R CMD build", "R CMD check", "R CMD INSTALL"),
  quiet = FALSE,
  debug = NA
)
```

## Arguments

- status:

  An integer specifying the exit code of the current R session.

- workdir:

  The working directory where the new R session should be launched from.
  If `NULL`, then the working directory that was in place when the
  startup package was first loaded. If using
  [`startup::startup()`](https://henrikbengtsson.github.io/startup/reference/startup.md)
  in an `.Rprofile` startup file, then this is likely to record the
  directory from which R itself was launched.

- rcmd:

  A character string specifying the command for launching R. The default
  is the same as used to launch the current R session, i.e.
  [`commandArgs()[1]`](https://rdrr.io/r/base/commandArgs.html).

- args:

  A character vector specifying zero or more command-line arguments to
  be appended to the system call of `rcmd`.

- envvars:

  A named character vector of environment variables to be set when
  calling R.

- as:

  A character string specifying predefined setups of `rcmd`, `args`, and
  `envvars`. For details, see below.

- quiet:

  Should the restart be quiet or not? If `NA` and `as == "current"`,
  then `quiet` is `TRUE` if the current R session was started quietly,
  otherwise `FALSE`.

- debug:

  If `TRUE`, debug messages are output, otherwise not.

## Value

Nothing.

## Predefined setups

Argument `as` may take the following values:

- `"current"`::

  (Default) A setup that emulates the setup of the current R session as
  far as possible by relaunching R with the same command-line call (=
  [`base::commandArgs()`](https://rdrr.io/r/base/commandArgs.html)).

- `"specified"`::

  According to `rcmd`, `args`, and `envvars`.

- `"R CMD build"`::

  A setup that emulates
  [`R CMD build`](https://github.com/wch/r-source/blob/R-3-4-branch/src/scripts/build)
  as far as possible.

- `"R CMD check"`::

  A setup that emulates
  [`R CMD check`](https://github.com/wch/r-source/blob/R-3-4-branch/src/scripts/check)
  as far as possible, which happens to be identical to the
  `"R CMD build"` setup.

- `"R CMD INSTALL"`::

  A setup that emulates
  [`R CMD INSTALL`](https://github.com/wch/r-source/blob/R-3-4-branch/src/scripts/INSTALL)
  as far as possible.

If specified, command-line arguments in `args` and environment variables
in `envvars` are *appended* accordingly.

## Known limitations

It is *not* possible to restart an R session running in *RGui* on
Microsoft Windows using this function.

It is *not* possible to restart an R session in the RStudio *Console*
using this function. However, it does work when running R in the RStudio
*Terminal*.

RStudio provides
[`rstudioapi::restartSession()`](https://rstudio.github.io/rstudioapi/reference/restartSession.html)
which will indeed restart the RStudio Console. However, it does not let
you control how R is restarted, e.g. with what command-line options and
what environment variables. Importantly, the new R session will have the
same set of packages loaded as before, the same variables in the global
environment, and so on.

## Examples

``` r
if (FALSE) { # \dontrun{
  ## Relaunch R with debugging of startup::startup() enabled
  startup::restart(envvars = c(R_STARTUP_DEBUG = TRUE))

  ## Relaunch R without loading user Rprofile files
  startup::restart(args = "--no-init-file")

  ## Mimic 'R CMD build' and 'R CMD check'
  startup::restart(as = "R CMD build")
  startup::restart(as = "R CMD check")
  ## ... which are both short for
  startup::restart(args = c("--no-restore"),
                   envvars = c(R_DEFAULT_PACKAGES="", LC_COLLATE="C"))
} # }
```
