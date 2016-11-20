# startup: Friendly R Startup Configuration

## Introduction

Calling `startup::startup()` in `~/.Rprofile`, will cause the following to occurs:

1. Files in the first existing directory of `paste0(Sys.genenv("R_ENVIRON_USER"), ".d")`, `~./.Renviron.d/` or `./.Renviron.d/` will be processes as .Renviron files.

2. Files in the first existing directory of `paste0(Sys.genenv("R_ENVIRON_USER"), ".d")`, `~./.Rprofile.d/` or `./.profile.d/` will be sourced as .Rprofile files.

3. If there are no errors, the `startup` package will be unloaded again leaving no trace of itself behind.

All relevant files, including those found recursively in subdirectories thereof, will be processed, except for those with file endings `*.txt`, `*.md` and `*~`.  Files such as `.Rhistory` and `.RData` are also ignored.


## Installation

Install `startup` using
```r
source('http://callr.org/install#HenrikBengtsson/startup')
```

Then call
```r
startup::install()
```
once.  This will append
```r
startup::startup()
```
to your `~/.Rprofile`.  The file will be create if missing.  This will also create directories `~/.Renviron.d/` and `~/.Rprofile.d/` if missing.  Alternatively, you can just add `startup::startup()` to your `~/.Rprofile` file manually.


## Usage

Just start R :)

To debug the startup process, use `startup::startup(debug = TRUE)` or set environment variable `R_STARTUP_DEBUG=TRUE`, e.g. on Linux one can do:
```r
$ R_STARTUP_DEBUG=TRUE R
```
This is will give informative messages during startup on which files are included and why.


## Conditional file names

If the name of a file consists of a `<key>=<value>` specification, then that file will only be included / used if the specification is fulfilled on the current system with the current R setup.  For instance, a file `~/.Rprofile.d/os=windows` will be ignored unless `startup::sysinfo()$os == "windows"`, i.e. the R session is started on a Windows system.

The following `startup::sysinfo()` keys are available for conditional inclusion of files by their file names:

* `interactive` - (logical) whether running interactively or not (as of `interactive()`)
* `nodename`    - (character) the host name (as of `Sys.info()[["nodename"]]`)
* `machine`     - (character) the machine type (as of `Sys.info()[["machine"]]`)
* `os`          - (character) the operating system (as of `.Platform$OS.type`)
* `sysname`     - (character) the system name (as of `Sys.info()[["sysname"]]`)
* `user`        - (character) the user name (as of `Sys.info()[["user"]]`)

To condition on more than one key, separate `<key>=<value>` pairs by commas (`,`), e.g. `~/.Rprofile.d/work,interactive=TRUE,os=windows`.  This also works for directory names.  For instance, `~/.Rprofile.d/os=windows/work,interactive=TRUE` will process `work,interactive=TRUE` if running on Windows and in interactive mode.


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
  repos <- c(repos, getOption("repos"))
  options(repos = repos)
})
```

## Installation
R package startup is only available via [GitHub](https://github.com/HenrikBengtsson/startup) and can be installed in R as:
```r
source('http://callr.org/install#HenrikBengtsson/startup')
```

### Pre-release version

To install the pre-release version that is available in branch `develop`, use:
```r
source('http://callr.org/install#HenrikBengtsson/startup@develop')
```
This will install the package from source.  



## Software status

| Resource:     | GitHub        | Travis CI       | Appveyor         |
| ------------- | ------------------- | --------------- | ---------------- |
| _Platforms:_  | _Multiple_          | _Linux & macOS_ | _Windows_        |
| R CMD check   |  | <a href="https://travis-ci.org/HenrikBengtsson/startup"><img src="https://travis-ci.org/HenrikBengtsson/startup.svg" alt="Build status"></a>   | <a href="https://ci.appveyor.com/project/HenrikBengtsson/startup"><img src="https://ci.appveyor.com/api/projects/status/github/HenrikBengtsson/startup?svg=true" alt="Build status"></a> |
| Test coverage |                     | <a href="https://codecov.io/gh/HenrikBengtsson/startup"><img src="https://codecov.io/gh/HenrikBengtsson/startup/branch/develop/graph/badge.svg" alt="Coverage Status"/></a>     |                  |
