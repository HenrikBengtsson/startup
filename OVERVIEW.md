## Introduction

When you start R, it will by default source a `.Rprofile` file if it exists.  This allows you to automatically tweak your R settings to meet your everyday needs.  For instance, you may want to set the default CRAN repository (`options("repos")`) so you don't have to choose one every time you install a package.

The [startup] package extends the default R startup process by allowing you to put multiple startup scripts in a common `.Rprofile.d` directory and have them all be sourced during the R startup process.  This way you can have one file to configure the default CRAN repository and another one to configure your personal [devtools] settings.
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

All relevant files in directories `.Renviron.d` and `.Rprofile.d`, including those found recursively in subdirectories thereof, will be processed, except for those with file endings `*.txt`, `*.md` and `*~`.  Files such as `.Rhistory` and `.RData` are also ignored.


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
This is will give informative messages during startup on which files are included and why.


## Conditional file names

If the name of a file consists of a `<key>=<value>` specification, then that file will only be included / used if the specification is fulfilled on the current system with the current R setup.  For instance, a file `~/.Rprofile.d/os=windows` will be ignored unless `startup::sysinfo()$os == "windows"`, i.e. the R session is started on a Windows system.

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
  - `rstudio`     - (logical) whether running in [RStudio] or not.
  - `wine`        - (logical) whether running on Windows via [Linux Wine] or not.

In addition, one can also conditionally include files based on availability of a package:

* `package`     - (character) whether a package is installed or not.

In addition to checking the availability, having `package=<name>` in the filename makes it clear that the startup file concerns settings specific to that package.

To condition on more than one key, separate `<key>=<value>` pairs by commas (`,`), e.g. `~/.Rprofile.d/work,interactive=TRUE,os=windows`.  This also works for directory names.  For instance, `~/.Rprofile.d/os=windows/work,interactive=TRUE` will process `work,interactive=TRUE` if running on Windows and in interactive mode.  Multiple packages may be specified.  For instance, `~/.Rprofile.d/package=devtools,package=future` will only be used if both the devtools and the future packages are installed.

It is also possible to negate a conditional filename test by using the `<key>!=<value>` specification.  For instance, `~/.Rprofile.d/package=doMC,os!=windows` will be processed if package `doMC` is installed and if not running on Windows.


## Examples
The below is a list of "real-world" example files:
```
.Renviron.d/
  +-- lang
  +-- libs
  +-- r_cmd_check
 
.Rprofile.d/
  +-- help,interactive=TRUE
  +-- interactive=TRUE
  +-- os=windows
  +-- repos
```
They are available as part of this package under `system.file(package = "startup")`, e.g.
```r
> f <- system.file(".Rprofile.d", "repos", package = "startup")
> file.show(f, type = "text")

local({
  repos <- c(CRAN = "https://cloud.r-project.org")
  if (.Platform$OS.type == "windows") {
     repos["CRANextra"] <- "https://www.stats.ox.ac.uk/pub/RWin"
  }
  options(repos = c(repos, getOption("repos"))
})
```

[startup]: https://cran.r-project.org/package=startup
[devtools]: https://cran.r-project.org/package=devtools
[RStudio]: https://www.rstudio.com/products/RStudio/
[Linux Wine]: https://www.winehq.org/
