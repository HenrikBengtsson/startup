## Introduction

When you start R, it will by default source a `.Rprofile` file if it exists.  This allows you to automatically tweak your R settings to meet your everyday needs.  For instance, you may want to set the default CRAN repository (`options("repos")`) so you don't have to choose one every time you install a package.

The [startup] package extends the default R startup process by allowing you to put multiple startup scripts in a common `.Rprofile.d` directory and have them all be sourced during the R startup process.  This way you can have one file to configure the default CRAN repository and another one to configure your personal devtools settings.
Similarly, you can use a `.Renviron.d` directory with multiple files defining different environment variables.  For instance, one file may define environment variable `LANGUAGE`, whereas another file may contain your private `GITHUB_PAT` key.
The advantages of this approach are that it gives a better overview when you list the files, makes it easier to share certain settings (= certain files) with other users, and enable you to keep specific files completely private (by setting the file privileges so only you can access those settings).


## How the R startup process works

When R starts, the following _user-specific_ setup takes place:

1. The _first_ `.Renviron` file found on the R startup search path is processed.  The search path is (in order): `Sys.getenv("R_ENVIRON_USER")`, `./.Renviron`, and `~/.Renviron`.  The format of this file is one `ENV_VAR=VALUE` statement per line, cf. `?.Renviron`.  _NOTE:_ Some environment variables must be set already in this step in order to be acknowledged by R, i.e. it is _too late_ to set some of them in Step 3a below.

2. The _first_ `.Rprofile` file found on the R startup search path is processed.  The search path is (in order): `Sys.getenv("R_PROFILE_USER")`, `./.Rprofile`, and `~/.Rprofile`.  The format of this file must be a valid R script (with a trailing newline), cf. `?.Rprofile`.

3. If the `.Rprofile` file (in Step 2) calls `startup::startup()` then the following will also take place:

   a. The _first_ `.Renviron.d` directory on the R startup search path is processed.  The search path is (in order): `paste0(Sys.getenv("R_ENVIRON_USER"), ".d")`, `./.Renviron.d`, and `~/.Renviron.d`.  The format of these files should be the same as for `.Renviron`.  _NOTE:_ Some environment variables must be set already in Step 1 above in order to be acknowledged by R.

   b. A set of handy R options that can be use in Step 3c are set.  Their names are prefixed `startup.session.` - see `?startup::startup_session_options` for details.

   c. The _first_ `.Rprofile.d` directory found on the R startup search path is processed.  The search path is (in order): `paste0(Sys.getenv("R_PROFILE_USER"), ".d")`, `./.Rprofile.d`, and `~/.Rprofile.d`.  The format of these files should be the same as for `.Rprofile`, that is, they must be valid R scripts.

   d. If no errors occur, the [startup] package will be unloaded, leaving no trace of itself behind, except for R options `startup.session.*` set in Step 3b - these will be erased if `startup::startup()` is called with `keep = NULL`.

All relevant files in directories `.Renviron.d` and `.Rprofile.d`, including those found recursively in subdirectories thereof, will be processed (in lexicographic order sorted under the `C` locale).
There are no restrictions on what the file names should be (except for the ones ignored as explained below).  For instance, for `.Renviron.d` you can use files without filename extensions whereas for `.Rprofile.d` you may want use files with filename extension `*.R`.  One advantage of using an `*.R` extension for Rprofile files, other than making it clear that it is an R script, is that it clarifies that it is a file and not a directory.  To avoid confusions, don't use an `*.R` extension for Renviron files because they are not R script per se (as some editors may warn you about).

Files with file extensions `*.txt`, `*.md` and `*~` are ignored as well as any files named `.Rhistory`, `.RData` and `.DS_Store`.  Directories named `__MACOSX` and their content are ignored.  Files and directories with names starting with two periods (`..`) are ignored, e.g. `~/.Rprofile.d/..my-tests/`.



## Installation

After installing the startup packages (see instructions at the end), call
```r
startup::install()
```
once.  This will append
```r
try(startup::startup())
```
to your `~/.Rprofile`.  The file will be created if missing.  This will also create directories `~/.Renviron.d/` and `~/.Rprofile.d/` if missing.  Alternatively, you can just add `try(startup::startup())` to your `~/.Rprofile` file manually.  The reason for using `try()` is for the case when startup is not installed and you try to install it, e.g. after upgrading R to a new major release.  Without `try()`, R fails to install startup (or any other package) because the R profile startup script produces an error complaining about startup not being available.


## Usage

Just start R :)

To debug the startup process, use `startup::startup(debug = TRUE)` or set environment variable `R_STARTUP_DEBUG=TRUE`, e.g. on Linux you can do:
```sh
$ R_STARTUP_DEBUG=TRUE R
```
This will produce time-stamped messages during startup specifying which files are included.


## Conditional file and directory names

If the name of a file consists of a `<key>=<value>` specification, then that file will be included / used only if the specification is fulfilled (on the current system with the current R setup).  For instance, a file `~/.Rprofile.d/os=windows.R` will be ignored unless `startup::sysinfo()$os == "windows"`, i.e. the R session is started on a Windows system.

The following `startup::sysinfo()` keys are available for conditional inclusion of files by their path names:

* Values:
  - `gui`         - (character) the graphical user interface (= `.Platform$GUI`)
  - `nodename`    - (character) the host name (= `Sys.info()[["nodename"]]`)
  - `machine`     - (character) the machine type (= `Sys.info()[["machine"]]`)
  - `os`          - (character) the operating system (= `.Platform$OS.type`)
  - `sysname`     - (character) the system name (= `Sys.info()[["sysname"]]`)
  - `user`        - (character) the user name (= `Sys.info()[["user"]]`)
  
* Flags:
  - `interactive` - (logical) whether running interactively or not (= `interactive()`)
  - `ess`         - (logical) whether running in [Emacs Speaks Statistics (ESS)] or not
  - `rstudio`     - (logical) whether running in [RStudio] or not
  - `wine`        - (logical) whether running on Windows via [Linux Wine] or not

You can also include files conditionally on whether a package is installed or not:

  - `package`     - (character) whether a package is installed or not

In addition to checking the availability, having `package=<name>` in the filename makes it clear that the startup file concerns settings specific to that package.

Any further `<key>=<value>` specifications with keys matching none of the above known keys are interpreted as system environment variables and startup will test such conditions against their values.  If `<key>` does not correspond to a known environment variable, then the condition is ignored.  For instance, a startup file or directory containing `LANGUAGE=fr` will be processed only if the environment variable `LANGUAGE` equals `fr` (or is not set).

To condition on more than one key, separate `<key>=<value>` pairs by commas, e.g. `~/.Rprofile.d/work,interactive=TRUE,os=windows.R`.  This also works for directory names.  For instance, `~/.Rprofile.d/os=windows/work,interactive=TRUE.R` will be processed if running on Windows and in interactive mode.  Multiple packages may be specified.  For instance, `~/.Rprofile.d/package=devtools,package=future.R` will be used only if both the devtools and the future packages are installed.

It is also possible to negate a conditional filename test by using the `<key>!=<value>` specification.  For instance, `~/.Rprofile.d/package=doMC,os!=windows.R` will be processed if package `doMC` is installed and the operating system is not Windows.


## Known limitations

### Setting environment variables during startup

Renviron startup files is a convenient and cross-platform way of setting environment variables during the R startup process.  However, for some of the environment variables that R consults must be set early on in the R startup process (immediately after Step 1), because R only consults them once.  An example(*) of environment variables that need to be set _no later than_ `.Renviron` (Step 1) are:

* `LC_ALL` - locale settings used by R, cf. `?locales`
* `R_LIBS_USER` - user's library path, cf. `?R_LIBS_USER`
* `R_DEFAULT_PACKAGES` - default set of packages loaded when R starts, cf. `?Rscript`

Any changes to these done in an `.Renviron.d/*` file (Step 3a), or via `Sys.setenv()` in `.Rprofile` (Step 2) or `.Rprofile.d/*` files (Step 3c), _will be ignored by R itself_ - despite being reflected by `Sys.getenv()`.

Furthermore, some environment variables can not even be set in `.Renviron` (Step 1) but must be set _prior_ to launching R.  This is because those variables are consulted by R very early on (prior to Step 1).  An example(*) of environment variables that need to be set _prior to_ `.Renviron` (Step 1):

* `HOME` - the user's home directory
* `TMPDIR`, `TMP`, `TEMP` - the parent of R's temporary directory,
  cf. `?tempdir`
* `MKL_NUM_THREADS` and `OMP_NUM_THREADS` - the default number of threads used by OpenMP etc, cf. _R Installation and Administration_
* `R_MAX_NUM_DLLS`, cf. `?dyn.load`
  
In other words, these variables have to be set using methods specific to the operating system or the calling shell, e.g. in Unix shells
```sh
$ export TMPDIR=/path/to/tmp
$ R
```
or per call as
```sh
R_MAX_NUM_DLLS=500 R
```

(*) For further details on which environment variables R consults and what they are used for by R, see the R documentation and help, e.g. `?EnvVar` and `?Startup`.


## Examples
Below is a list of "real-world" example files:
```
.Renviron.d/
  +-- lang
  +-- libs
  +-- r_cmd_check
  +-- secrets
 
.Rprofile.d/
  +-- interactive=TRUE/
      +-- help.start.R
      +-- misc.R
	  +-- package=fortunes.R
  +-- os=windows.R
  +-- repos.R
```
They are available as part of this package under `system.file(package = "startup")`, e.g.
```r
> f <- system.file(".Rprofile.d", "repos.R", package = "startup")
> file.show(f, type = "text")

local({
  repos <- c(CRAN = "https://cloud.r-project.org")
  if (.Platform$OS.type == "windows") {
     repos["CRANextra"] <- "https://www.stats.ox.ac.uk/pub/RWin"
  }
  options(repos = c(repos, getOption("repos")))
})
```

[startup]: https://cran.r-project.org/package=startup
[Emacs Speaks Statistics (ESS)]: https://ess.r-project.org/
[RStudio]: https://www.rstudio.com/products/RStudio/
[Linux Wine]: https://www.winehq.org/
