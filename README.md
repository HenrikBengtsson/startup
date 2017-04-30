# startup: Friendly R Startup Configuration

## Introduction

When you start R, it will by default source a `.Rprofile` file if it exists.  This allows you to automatically tweak your R settings to meet your everyday needs.  For instance, you may want to set the default CRAN repository (`options("repos")`) so you don't have to choose one every time you install a package.

The [startup] package extends the default R startup process by allowing you to put multiple startup scripts in a common `.Rprofile.d` directory and have them all be sourced during the R startup process.  This way you can have one file to configure the default CRAN repository and another one to configure your personal devtools settings.
Similarly, you can use a `.Renviron.d` directory with multiple files defining different environment variables.  For instance, one file may define environment variable `LANGUAGE`, whereas another file may contain your private `GITHUB_PAT` key.
The advantages of this approach are that it gives a better overview when you list the files, it makes it easier to share certain settings (= certain files) with other users, and you can keeping specific files completely private by setting the file privileges so only you can access those settings.


## How the R startup process works

When R starts, the following _user-specific_ setup takes place:

1. The _first_ `.Renviron` file found on the R startup search path to be processed.  The search path is (in order): `Sys.getenv("R_ENVIRON_USER")`, `./.Renviron`, and `~/.Renviron`.

2. The _first_ `.Rprofile` file found on the R startup search path to be processed.  The search path is (in order): `Sys.getenv("R_PROFILE_USER")`, `./.Rprofile`, and `~/.Rprofile`.

3. If the `.Rprofile` file (in Step 2) calls `startup::startup()` then the following will also take place:

  a. The _first_ `.Renviron.d` directory on the R startup search path to be processed.  The search path is (in order): `paste0(Sys.getenv("R_ENVIRON_USER"), ".d")`, `./.Renviron.d`, and `~/.Renviron.d`.
  
  b. The _first_ `.Rprofile.d` directory found on the R startup search path to be processed.  The search path is (in order): `paste0(Sys.getenv("R_PROFILE_USER"), ".d")`, `./.Rprofile.d`, and `~/.Rprofile.d`.
  
  c. If there are no errors, the [startup] package will be unloaded afterward leaving no trace of itself behind.

All relevant files in directories `.Renviron.d` and `.Rprofile.d`, including those found recursively in subdirectories thereof, will be processed.  There are no restrictions on what the file names should be.  For instance, for `.Rprofile.d`, you may use file names with and without extension `*.R`.  One advantage of using an `*.R` extension, other than making it clear that it is an Rscript, is that it clarifies that it is a file and not a directory.  Files with file extensions `*.txt`, `*.md` and `*~` are ignored as well as any files named `.Rhistory`, `.RData` and `.DS_Store`.  Directories named `__MACOSX` and their content are ignored.  Files and directories with names starting with two periods (`..`) are ignored, e.g. `~/.Rprofile.d/..my-tests/`.



## Installation

After installing the startup packages (see instructions at the end), call
```r
startup::install()
```
once.  This will append
```r
startup::startup()
```
to your `~/.Rprofile`.  The file will be created if missing.  This will also create directories `~/.Renviron.d/` and `~/.Rprofile.d/` if missing.  Alternatively, you can just add `startup::startup()` to your `~/.Rprofile` file manually.


## Usage

Just start R :)

To debug the startup process, use `startup::startup(debug = TRUE)` or set environment variable `R_STARTUP_DEBUG=TRUE`, e.g. on Linux one can do:
```sh
$ R_STARTUP_DEBUG=TRUE R
```
This is will give timestamped messages during startup on which files are included.


## Conditional file names

If the name of a file consists of a `<key>=<value>` specification, then that file will only be included / used if the specification is fulfilled on the current system with the current R setup.  For instance, a file `~/.Rprofile.d/os=windows.R` will be ignored unless `startup::sysinfo()$os == "windows"`, i.e. the R session is started on a Windows system.

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
  - `ess`         - (logical) whether running in [Emacs Speaks Statistics (ESS)] or not.
  - `rstudio`     - (logical) whether running in [RStudio] or not.
  - `wine`        - (logical) whether running on Windows via [Linux Wine] or not.

In addition, one can also conditionally include files based on availability of a package:

* `package`     - (character) whether a package is installed or not.

In addition to checking the availability, having `package=<name>` in the filename makes it clear that the startup file concerns settings specific to that package.

Any further `<key>=<value>` specification with keys not matching any of the above known keys are interpreted as system environment variables and check against them.  If `<key>` does not correspond to a known environment variables, then the condition is ignored.  For instance, a startup file or directory containing `LANGUAGE=fr` will only be processed if the environment variable `LANGUAGE` equals `fr` (or is not set).

To condition on more than one key, separate `<key>=<value>` pairs by commas (`,`), e.g. `~/.Rprofile.d/work,interactive=TRUE,os=windows.R`.  This also works for directory names.  For instance, `~/.Rprofile.d/os=windows/work,interactive=TRUE.R` will process `work,interactive=TRUE.R` if running on Windows and in interactive mode.  Multiple packages may be specified.  For instance, `~/.Rprofile.d/package=devtools,package=future.R` will only be used if both the devtools and the future packages are installed.

It is also possible to negate a conditional filename test by using the `<key>!=<value>` specification.  For instance, `~/.Rprofile.d/package=doMC,os!=windows.R` will be processed if package `doMC` is installed and if not running on Windows.


## Examples
The below is a list of "real-world" example files:
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

## Installation
R package startup is available on [CRAN](https://cran.r-project.org/package=startup) and can be installed in R as:
```r
install.packages('startup')
```

### Pre-release version

To install the pre-release version that is available in Git branch `develop` on GitHub, use:
```r
source('http://callr.org/install#HenrikBengtsson/startup@develop')
```
This will install the package from source.  



## Contributions

This Git repository uses the [Git Flow](http://nvie.com/posts/a-successful-git-branching-model/) branching model (the [`git flow`](https://github.com/petervanderdoes/gitflow-avh) extension is useful for this).  The [`develop`](https://github.com/HenrikBengtsson/startup/tree/develop) branch contains the latest contributions and other code that will appear in the next release, and the [`master`](https://github.com/HenrikBengtsson/startup) branch contains the code of the latest release, which is exactly what is currently on [CRAN](https://cran.r-project.org/package=startup).

Contributing to this package is easy.  Just send a [pull request](https://help.github.com/articles/using-pull-requests/).  When you send your PR, make sure `develop` is the destination branch on the [startup repository](https://github.com/HenrikBengtsson/startup).  Your PR should pass `R CMD check --as-cran`, which will also be checked by <a href="https://travis-ci.org/HenrikBengtsson/startup">Travis CI</a> and <a href="https://ci.appveyor.com/project/HenrikBengtsson/startup">AppVeyor CI</a> when the PR is submitted.


## Software status

| Resource:     | CRAN        | Travis CI       | Appveyor         |
| ------------- | ------------------- | --------------- | ---------------- |
| _Platforms:_  | _Multiple_          | _Linux & macOS_ | _Windows_        |
| R CMD check   | <a href="https://cran.r-project.org/web/checks/check_results_startup.html"><img border="0" src="http://www.r-pkg.org/badges/version/startup" alt="CRAN version"></a> | <a href="https://travis-ci.org/HenrikBengtsson/startup"><img src="https://travis-ci.org/HenrikBengtsson/startup.svg" alt="Build status"></a>   | <a href="https://ci.appveyor.com/project/HenrikBengtsson/startup"><img src="https://ci.appveyor.com/api/projects/status/github/HenrikBengtsson/startup?svg=true" alt="Build status"></a> |
| Test coverage |                     | <a href="https://codecov.io/gh/HenrikBengtsson/startup"><img src="https://codecov.io/gh/HenrikBengtsson/startup/branch/develop/graph/badge.svg" alt="Coverage Status"/></a>     |                  |
