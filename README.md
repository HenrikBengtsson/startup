# startup: Friendly R Startup Configuration

## Usage

Add
```r
startup::everything()$unload()
```
to `~/.Rprofile` (or `./.Rprofile`).

This will cause all files under (recursively)

1. `./.Renviron.d/` and `~./.Renviron.d/` to be processed as `.Renviron` files.

2. `./.profile.d/` and `~./.Rprofile.d/` to be sourced as `.Rprofile` files.

When done, the `startup` package will be unloaded again.


## Conditional file names

If the name of a file consists of a `<key>=<value>` specification, then that file will only be included / used if the specification is fulfilled on the current system with the current R setup.  For instance, a file `~/.Rprofile.d/os=windows` will be ignored unless `startup::sysinfo()$os == "win"`, i.e. the R session is started on a Windows system.

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
 They are available as part of this package under `system.file("examples", package = "startup")`, e.g.
 ```r
 > f <- system.file("examples", ".Rprofile.d", "repos", package = "startup")
 > file.show(f, type = "text")

local({
  repos <- c(
    CRAN="https://cloud.r-project.org",
    CRANextra = if (.Platform$OS.type == "windows") {
      "https://www.stats.ox.ac.uk/pub/RWin"
    },
    getOption("repos")
  )

  # Keep only unique existing ones
  repos <- repos[!is.na(repos) && nzchar(repos)]
  names <- names(repos)
  repos <- repos[!(nzchar(names) & duplicated(names))]
  
  options(repos=repos)
})
```

## Installation
R package startup is only available via [GitHub](https://github.com/HenrikBengtsson/startup) and can be installed in R as:
```r
source('http://callr.org/install#HenrikBengtsson/startup')
```




## Software status

| Resource:     | GitHub        | Travis CI       | Appveyor         |
| ------------- | ------------------- | --------------- | ---------------- |
| _Platforms:_  | _Multiple_          | _Linux & macOS_ | _Windows_        |
| R CMD check   |  | <a href="https://travis-ci.org/HenrikBengtsson/startup"><img src="https://travis-ci.org/HenrikBengtsson/startup.svg" alt="Build status"></a>   | <a href="https://ci.appveyor.com/project/HenrikBengtsson/startup"><img src="https://ci.appveyor.com/api/projects/status/github/HenrikBengtsson/startup?svg=true" alt="Build status"></a> |
| Test coverage |                     | <a href="https://codecov.io/gh/HenrikBengtsson/startup"><img src="https://codecov.io/gh/HenrikBengtsson/startup/branch/develop/graph/badge.svg" alt="Coverage Status"/></a>     |                  |
