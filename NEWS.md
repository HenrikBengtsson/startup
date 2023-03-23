# Version (development version)

## Bug Fixes

 * startup::check() no longer warns when R sets environment variables
   'R_LIBS_USER' and 'R_LIBS_SITE' to the default folders that do not
   exist by default.

 * startup::check() would report on an incorrect default value if R
   option `encoding` or `stringsAsFactors` was set during startup to
   an unsafe value.


# Version 0.19.0 (2022-10-15)

## New Features

 * An R script in environment variable `R_STARTUP_FILE` will be
   evaluated by `startup::startup()` after Renviron and Rprofile files
   have been processed, and after any `R_STARTUP_INIT` code.  For
   example, `R_STARTUP_FILE="setup.R" R` launches R, processes all R
   startup files, and at the end parses and evaluates file 'setup.R'.
   
 * `sysinfo()` gained field `quiet`, which is TRUE if `R` or `Rscript`
   was called with command-line options `-q`, `--quiet`, or `--silent`.

 * `sysinfo()` gained field `save`, which is TRUE if `R` or `Rscript`
   was called with command-line options `--save`, FALSE if called with
   `--no-save`, and otherwise NA.

## Miscellaneous

 * Warnings on misconfigured environments and R options are now
   produced at most once. Previously, duplicated warnings with
   identical messages could be produced.

## Bug Fixes

 * `startup(debug = TRUE)` would report file information on `R_PROFILE`
   and `R_PROFILE_USER` files as if they were Renviron files, not
   Rprofile files.
   

# Version 0.18.0 (2022-05-14)

## New Features

 * Now `startup::startup(debug = TRUE)` reports on any environment
   variables, options, global variables, locale settings that were
   added, removed, and changed while processing an Rprofile file.

 * `startup::startup(debug = TRUE)` now reports on any changes to the
   current working directory and the R library path while processing
   an Rprofile file.

 * `startup::startup(debug = TRUE)` already reported on updates to the
   state of R's random number generator (RNG). Now it also reports on
   updates to the RNG kind, including what the change was.
   

# Version 0.17.0 (2022-02-23)

## New Features

 * `startup::startup()` now searches for Renviron.d/ and Rprofile.d/ (note,
   without leading periods) in user's configuration folder in a way that is
   compatible with `tools::R_user_dir()` of R (>= 4.0.0) and that follows
   operating-system standards. For example, for Linux ~/.config/R/startup/,
   for macOS ~/Library/Preferences/org.R-project.R/R/startup/, and for
   MS Windows %LOCALAPPDATA%/R/cache/R/startup/. If environment variable
   `XDG_CONFIG_HOME` is set, then ${XDG_CONFIG_HOME}/R/startup/ is used.
   For now, `startup::install()` will continue to create ~/.Renviron.d/ and
   ~/.Rprofile.d/ by default.

 * `startup::install()` gained argument `make_dirs` to control whether
   directories .Renviron.d/ and .Rprofile.d/ should be created, if missing.
   
 * Add `on_session_enter()` for registering R functions and expressions to be
   evaluated at the end of R's startup process via a custom `.First()` that is
   added to the global environment.  If there is a `.First()` function on the
   search path, including any preexisting one in the global environment, that
   is called at the end.

 * Add `on_session_exit()` for registering R functions and expressions to be
   called at the very end when the R session terminates.

 * Now `startup()` warns about non-standard, platform-specific capitalization of
   Renviron and Rprofile file names.  For example, although ~/.RProfile works
   on MS Windows and macOS with non-case sensitive file systems, the officially
   supported file name is ~/.Rprofile.

 * Now `startup(debug = TRUE)` reports on `.Last()` and `.Last.sys()`.

 * Now `startup(debug = TRUE)` gives a note if it detects that an Rprofile
   script updated the state of R's random number generator (RNG).

 * Harmonized cache folder options toward `tools::R_user_dir()` of R (>= 4.0.0).

## Bug Fixes

 * `startup(unload = TRUE)` failed when there was an .RData file and environment
   variable `R_STARTUP_RDATA` or R option `startup.rdata` specifies `"prompt"`.



# Version 0.16.0 (2021-11-20)

## New Features

 * Now `startup(debug = TRUE)` reports on `R_SCRIPT_DEFAULT_PACKAGES`.

 * Now `startup(debug = TRUE)` reports on `tempdir()` and environment variables
   `TMPDIR`, `TMP`, and `TEMP` that controls the root of the temporary folder.

 * Now it is sufficient to call `startup(dryrun = TRUE)` to see what the R
   startup would have been.  Previously one would also have to specify
   `debug = TRUE`.

 * Now `startup(debug = TRUE)` reports on packages loaded, attached, unloaded,
   and detached per Rprofile file processed.  It also reports on other
   environments attached and detached.

 * Now `startup(debug = TRUE)` reports also on the Rprofile file in the **base**
   package, i.e. `system.file("R", "Rprofile", package = "base")`.

 * `startup::startup(check = TRUE)` no longer warns if environment variables
   `R_LIBS_SITE` or `R_LIBS_USER` have value NULL, which in R (>= 4.2.0)
   corresponds to setting them to be empty.
   
## Bug Fixes

 * `startup::restart(quiet = TRUE)` would give an error in radian saying
   `--quiet` is not supported, but it's supported in radian (>= 0.2.8)
   since 2018-08-27.
    

# Version 0.15.0 (2020-09-03)

## New Features

 * `startup(debug = TRUE)` now reports on number of lines and file size also
   for the `R_TESTS` file.

 * `startup(debug = TRUE)` [sic!] now checks that the environment variables that
   the different Renviron files set are actually set and produce an informative
   warning message if not. This confirms that, at least for R 4.0.2 for Windows,
   Rgui does *not* process ~/.Renviron unless Rgui is launched from that folder.

 * Using regular, non-fancy single quotes in any output produced.

## Bug Fixes

 * Package tests could attempt to backup and update ~/.Rprofile, e.g. if
   it did not have a newline on the last line.


# Version 0.14.1 (2020-04-01)

## New Features

 * Add R options as an alternative to corresponding environment variables,
   e.g. added `startup.disable` (`R_STARTUP_DISABLE`), `startup.init`
   (`R_STARTUP_INIT`), and `startup.rdata` (`R_STARTUP_RDATA`).

## Documentation

 * Add `help("startup.options", package = "startup")`, which lists environment
   variables and R options that the **startup** package use.

## Bug Fixes
   
 * The new default of option `stringsAsFactors` in R (>= 4.0.0) would trigger
   a startup warning.

 * It was not possible to disable the validation of R option `error` and
   environment variables such as `R_LIBS_USER`, `R_PROFILE_SITE`, and
   `R_CHECK_ENVIRON`.  These validations can now be disabled by specifying
   argument `check = FALSE`, or the corresponding R option, or environment
   variable.  Validation of `error` specifically can be disable by adding
   `"error"` to environment variable `R_STARTUP_CHECK_OPTIONS_IGNORE` or to
   option `startup.check.options.ignore`. The default is to ignore `error`.


# Version 0.14.0 (2019-12-09)

## Significant Changes

 * `startup(all = TRUE)` now processes any startup folders in the home directory
   _before_ those in the current working directory.  Previously it was vice
   verse. With the new way, it is possible to override settings made in
   ~/.Renviron.d/ or ~/.Rprofile.d/ with custom ones in local ./.Renviron.d/
   and ./.Rprofile.d/ folders.

## New Features

 * Setting environment variable `R_STARTUP_RDATA` to `"remove"` will cause an
   existing './.RData' file to be skipped by automatically removing it.
   If `"rename"`, it will be renamed to './.RData.YYYYMMDD_hhmmss' where the
   timestamp is the last time the file was modified.  If `"prompt"`, then the
   user is prompted whether they want to load the file or rename it.  In
   non-interactive session, `"prompt"` will fallback to loading by default.
   To fallback to renaming the file, use `"prompt,rename"`.  Thus, setting
   `R_STARTUP_RDATA=rename` in an .Renviron file will make sure no .RData
   file is ever loaded while still preserving them.

 * RStudio Console: The only way to prompt a user during the R startup process
   in the RStudio Console is via a graphical popup window.  Because of this,
   `R_STARTUP_RDATA=prompt` will trigger a popup window in RStudio if there is
   a .RData file.

## Bug Fixes

 * `startup(debug = TRUE)` would not only report on the name of an environment
   variable, but also parts of its value, if the value contained equal signs.

 * The source information, that is, the filename and line locations, were
   dropped from functions defined via `startup()`.  To get the filename where
   a function was defined use `getSrcFilename(my_fcn, full.names = TRUE)`.
 
 * RStudio: Using **renv** together with `startup()` while in the RStudio Console
   would produce a false warning on the `error` option being set.


# Version 0.13.0 (2019-10-27)

## New Features

 * `startup::startup()` will return immediately without processing R startup
   files if environment variable `R_STARTUP_DISABLE` is set to TRUE.

 * Added flag `radian` to `sysinfo()` indicating whether R runs in radian
   (previously known as rtichoke and rice) or not.  Please stop using the
   `rice` and `rtichoke` flags.

 * The `startup::startup()` code snipped injected in the .Rprofile file by
   `startup::install()` now prefix error messages with '.Rprofile error: '
   to help troubleshooting errors.

## Bug Fixes

 * The validation of `R_LIBS`, `R_LIBS_SITE`, `R_LIBS_USER` by `startup::check()`
   had a `_R_CHECK_LENGTH_1_LOGIC2_` bug.
   
 * The startup checks asserting that `update.packages()` is not called would
   pick up not only those with the period ('.') but any character in that
   position.

## Deprecated and Defunct

 * `startup::startup()` no longer warn about startup files with non-declared key
   names being skipped. This warning was introduced in **startup** 0.10.0 due to
   how such files were filtered out.


# Version 0.12.0 (2019-05-27)

## Significant Changes

 * Renviron and Rprofile startup files that use `<key>!=<value>` filters with
   non-defined keys are now included.  Previously they were skipped.  Note
   that `<key>=<value>` files are indeed skipped when `<key>` is not defined.

 * `startup()` now produces an informative warning if it detects that an R
   option that is considered unsafe to change from its default, e.g. changing
   `encoding` other than in interactive mode may break package installations
   and changing `stringsAsFactors` will summon the dead.

## New Features

 * Added support for `when=<periodicity>` file declarations, where `<periodicity>`
   can be 'once', 'hourly', 'daily', 'weekly', 'fortnightly', and 'monthly'.
   A startup file with such a declaration will be processed at most once per
   `<periodicity>`, e.g. a file with 'when=daily' somewhere in the pathname will
   be processed once per day.  The periodicity is based on the walltime in the
   local time zone, e.g. if a file with 'when=daily' was processed one minute
   before midnight, it will be processed again if an R session is started one
   minute past midnight.  Updating the file timestamp of a 'when' file will
   reset its timer.

 * Code in environment variable `R_STARTUP_INIT` will now be evaluated by
   `startup::startup()` after Renviron and Rprofile files have been processed.
   For example, `R_STARTUP_INIT="x <- 1" R` will launch R with `x == 1`.

 * `startup(debug = TRUE)` now also reports on `.First()`.

 * The messages of warnings and errors produced by the **startup** package itself
   now mention which startup function they originate from.  This helps to
   identify the origin of these when produced during the R startup process.

 * Added `warn()`, which produces a warning with information on which R source
   file it was produced in, if any.

## Miscellaneous

 * Renamed example folders .Renviron.d/ and .Rprofile.d/ installed as part
   of the package to Renviron.d/ and Rprofile.d/ without the leading period.
   This was simply done to avoid `R CMD check --as-cran` NOTEs.

## Bug Fixes

 * `startup()` did not ignore files with names such as #foo.R#.
 
## Deprecated and Defunct

 * Removed defunct `renviron()` and `rprofile()`. Use `renviron_d()` and `rprofile_d()`.
 

# Version 0.11.0 (2018-08-26)

## New Features

 * `startup(debug = TRUE)` now also displays the expanded path to any file or
   folder listed.  It also gives information on files that known environment
   variables (e.g. `R_ENVIRON_USER`) point to.  For Renviron files, it also
   reports on names of the environment variables set in each of those files.

 * `startup(debug = TRUE)` reports on the search path and loaded namespaces,
   and what packages will be attached after R's startup finishes.

 * Added character `dirname` to `sysinfo()` specifying the basename of the
   current working directory.

 * `startup(check = TRUE)`, warns if `R_ENVIRON`, `R_ENVIRON_USER`, `R_PROFILE`,
   `R_PROFILE_USER`, `R_BUILD_ENVIRON`, or `R_CHECK_ENVIRON` specifies non-existing
   files.

 * `startup::check(fix = TRUE)` now returns the pathnames of any files that
   needed to be fixed and was successfully updated.

 * RStudio: `startup()` now gives an informative warning if option `error` is
   set during the R startup and it will be overridden by RStudio's debug
   settings.

 * Windows: Calling `startup::restart()` in the Windows RGui now produces an
   error clarifying that the RGui cannot be restarted this way.


## Bug Fixes

 * `startup::install()` would append the `startup::startup()` statement to the
   last line in .Rprofile if that line (incorrectly) did not have a newline.

 * `startup::startup(check = TRUE)` would give "Error in if (!eof_ok(file)) { 
   argument is of length zero" on Windows if the Rprofile file checked is
   a symbolic link.
   

# Version 0.10.0 (2018-03-31)

## Significant Changes

 * Renviron and Rprofile startup files that use `<key>=<value>` filters with
   non-declared keys are skipped.  Previously they were always processed.
   This update makes it easier to include "secrets", e.g. files in folder
   ~/.Renviron.d/private/SECRET=banana/ will only be included if the
   environment variable `SECRET` is set to exactly 'banana'.  An informative
   warning, which can be disabled, will be produced by **startup** 0.10.* until
   **startup** 0.11.0 is released.

## New Features

 * Added `is_debug_on()` which returns TRUE if the startup debug mode is on.
   To control the debug mode, see `?startup::startup`.

 * `startup(debug = TRUE)` reports on several `R_*` environment variables.
   
 * `restart()` gained argument `quiet` for controlling whether the restart
   should be quiet or not.

 * Added flag `microsoftr` to `sysinfo()` indicating whether R runs in
   Microsoft R Open or not.

 * Added flag `pqr` to `sysinfo()` indicating whether running pqR ("A Pretty
   Quick # Version of R"), or not.

 * Added flag `rstudioterm` to `sysinfo()` indicating whether R runs in an
   RStudio Terminal or not.  To test whether R runs via the RStudio Console,
   use the `rstudio` flag.

 * Added flag `rtichoke` to `sysinfo()` indicating whether R runs in rtichoke
   (previously known as Rice) or not.  Please stop using the `rice` flag and
   start using the `rtichoke` instead (both have identical values).

 * The `ess` flag of `sysinfo()` is now based on whether "ESSR" is in `search()` or
   not - used to check for environment variable `EMACS` equaling "t" or not.

 * Now `startup::restart()` also work when running R via rtichoke.

## Bug Fixes

 * `startup::restart()` would not work in the RStudio Terminal.  Note that it
   does not work in the RStudio Console due to limitations in RStudio.

 * On Windows, `startup::startup()` would produce a false warning on non-existing
   `R_LIBS_USER` folders.


# Version 0.9.0 (2018-01-11)

## New Features

 * Added `restart()` for restarting the current R session.  It can also be used
   to adjust various R command-line arguments and environment variables, e.g.
   `restart(as = "R CMD build")` mimics the `R CMD build` setup as far as
   possible.


# Version 0.8.0 (2017-10-19)

## New Features

 * Added `startup::current_script()` which returns the .Rprofile.d/ pathname
   that is currently processed by `startup::startup()`.
   
 * Added flag `rice` to `sysinfo()` indicating whether R runs via Rice or not,
   meaning it can be used as a file and directory name tag, e.g. rice=TRUE.
 
 * `startup(debug = TRUE)` outputs much more information on what has taken place
   and what will take place through R's startup process.

 * `startup()` gained argument `check` for controlling whether the content of
   startup files should be validated or not.

 * `check()`, and therefore also `startup(check = TRUE)`, warns if `R_LIBS`,
   `R_LIBS_SITE`, or `R_LIBS_USER` specifies non-existing directory.
   
## Deprecated and Defunct

 * `renviron()` and `rprofile()` are now defunct.  Removed `api()$renviron()`
   and `api()$rprofile()`.  Use `renviron_d()` and `rprofile_d()` instead.

## Bug Fixes

 * Now `install(backup = TRUE)` guarantees that the .Rprofile file is backed up,
   otherwise, an error is produced.  Previously it could silently fail if a
   backup file with the exact same name already existed.


# Version 0.7.0 (2017-09-07)

## Significant Changes

 * Package requires R (>= 2.14.0; Oct 2011) - was R (>= 2.13.0; Apr 2011).

## New Features

 * Convenient session details are now gathered and recorded as R options
   immediately after processing '.Renviron.d' files.  These options, prefixed
   `startup.session.`, are available while processing '.Rprofile.d' files and,
   by default, also after `startup::startup()` has completed.  For information
   on session details recorded, see `help("startup_session_options")`.

 * Added a package vignette (available only in R >= 3.0.2).
 
 
# Version 0.6.1 (2017-05-17)

## Bug Fixes

 * `startup()` ignores more of the hidden files and folders that macOS may create
   and which should not be sourced during startup.  For instance, when copying
   a file 'foo.R' to a non-macOS file system, an auxiliary file '._foo.R' may
   be created as well.
 

# Version 0.6.0 (2017-05-01)

## Significant Changes

 * Package requires R (>= 2.13.0; Apr 2011) - was R (>= 2.12.0; Oct 2010).

## New Features

 * New conditional `<key>=<value>` specification: an unknown `<key>` (i.e. one
   that is not one of the known `sysinfo()` fields or 'package') will be
   interpreted as the name of an environment variable.  For instance, files
   path/LANGUAGE=en/*.R will be included only if system environment variable
   `LANGUAGE` equals 'en' (or is not set).

 * `startup::install()` now injects `try(startup::startup())` such that 
   `install.packages("startup")` will work even when **startup** is not installed,
   e.g. after a major-version R update.

 * `startup::install()` and `startup::uninstall()` now output messages on what is
   done and why, and they now return the R startup file modified. They also
   produce a warning if **startup** is already installed or uninstalled,
   respectively.

 * `startup::install()` gained argument `overwrite` to control whether to append
   (default) to a pre-existing R startup file or to overwrite it.

 * ROBUSTNESS: Backups now assert that not only the backup files are created,
   but also that they have the same file size as the original file.


# Version 0.5.0 (2017-02-13)

## New Features

 * Startup directory or file names that start with two or more periods are now
   excluded, e.g. ~/.Rprofile.d/..hide/test.R.

 * `startup()` protects against attempts to update R packages also via
   `pacman::p_up()` in addition to `utils::update.packages()`.

 * Added flag `ess` to `sysinfo()` indicating whether R runs under Emacs Speaks
   Statistics (ESS) or not.

 * `startup(debug = TRUE)` detects if `R_TESTS` is set and reports which the file
   is and that the **base** package has already processed it.

## Bug Fixes

 * Now `startup()` ignores macOS files named .DS_Store and directories named
   __MACOSX (and their content).  Previously, such files could result
   in startup errors.
 

# Version 0.4.0 (2016-12-22)

## New Features

 * Now it is possible to do negated filename specifications, e.g.
   hpc,package=future/os!=windows.
   
 * Filename flags can now be specified a TRUE, FALSE, T, F, 1, and 0 (non-case
   sensitive), e.g. interactive=false and interactive=0.
   
 * Added element `gui` to `sysinfo()`.
 
 * Added flags `rstudio` and `wine` to `sysinfo()` indicating whether R runs via
   RStudio and via Linux Wine, respectively.
   
 * New conditional `<key>=<value>` specification: Directory and file names
   containing a `package=<name>` specification will be processed if and only if
   package `<name>` is installed.
   
 * Errors occurring while sourcing an Rprofile file now also contain
   information about in file the error occurred.  Lines with invalid syntax in
   Renviron files are ignored with a message outputted saying so.  Due to
   limitations in how `base::readRenviron()` works, it is not possible to detect
   these errors nor capture the outputted message.
  
 * Now objects are auto printed to match the behavior of the R startup process.
  
 * `startup(debug = TRUE)` now outputs time stamps since start per entry.

## Deprecated and Defunct

 * `renviron()` and `rprofile()` were renamed to `renviron_d()` and `rprofile_d()`,
   respectively.

## Bug Fixes

 * A file extension *.R would incorrectly become part of the `<value>` in a
   trailing `<key>=<value>` specification.
  
 * Now `R_STARTUP_DEBUG=TRUE` also works for Rscript; used to work only for the
   R executable.

 * Some macOS backup files would not be filtered out when running on Windows.
 

# Version 0.3.0 (2016-11-21)

 * No updates.  First submission to CRAN.


# Version 0.2.0

## New Features

 * Add arguments `sibling = FALSE` to `startup()`.  If `sibling = TRUE`, the
   corresponding startup file needs to exist in the same location as the
   directory in order for the directory to be processed.


# Version 0.1.0

 * Package created. Adopted from a specialized .Rprofile script.
