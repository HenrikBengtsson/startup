## Introduction

Calling `startup::startup()` in `~/.Rprofile`, will cause all files under

1. `~./.Renviron.d/` and then `./.Renviron.d/` to be processed as `.Renviron` files.

2. `~./.Rprofile.d/` and then `./.profile.d/` to be sourced as `.Rprofile` files.
3. If there are no errors, the `startup` package will be unloaded again leaving no trace of itself behind.

All relevant files, including those found recursively in subdirectories thereof, will be processed, except for those with file endings `*.txt`, `*.md`, `*.Rhistory` and `*.RData`.


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
to your `~/.Rprofile` and create it if missing.  It will also create directories `~/.Renviron.d/` and `~/.Rprofile.d/` if missing.  Alternatively, you can just add `startup::startup()` to your `~/.Rprofile` file manually.


## Usage

Just start R :)


## Conditional file names

If the name of a file consists of a `<key>=<value>` specification, then that file will only be included / used if the specification is fulfilled on the current system with the current R setup.  For instance, a file `~/.Rprofile.d/os=windows` will be ignored unless `startup::sysinfo()$os == "windows"`, i.e. the R session is started on a Windows system.

The following `startup::sysinfo()` keys are available for conditional inclusion of files by their file names:

* `interactive` - (logical) whether running interactively or not (as of `interactive()`)
* `nodename`    - (character) the host name (as of `Sys.info()[["nodename"]]`)
* `machine`     - (character) the machine type (as of `Sys.info()[["machine"]]`)
* `os`          - (character) the operating system (as of `.Platform$OS.type`)
* `sysname`     - (character) the system name (as of `Sys.info()[["sysname"]]`)
* `user`        - (character) the user name (as of `Sys.info()[["user"]]`)

To condition on more than one key, separate `<key>=<value>` pairs by commas (`,`), e.g. ``~/.Rprofile.d/work,interactive=TRUE,os=windows`.


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
  repos <- c(
    CRAN = "https://cloud.r-project.org",
    CRANextra = if (.Platform$OS.type == "windows") {
      "https://www.stats.ox.ac.uk/pub/RWin"
    },
    getOption("repos")
  )

  # Keep only unique existing ones
  repos <- repos[!is.na(repos) && nzchar(repos)]
  names <- names(repos)
  repos <- repos[!(nzchar(names) & duplicated(names))]
  
  options(repos = repos)
})
```
