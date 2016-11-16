## Usage

Add
```r
startup::startup()
```
to `~/.Rprofile` (or `./.Rprofile`).

This will cause all files (found recursively) under

1. `./.Renviron.d/` and `~./.Renviron.d/` to be processed as `.Renviron` files.

2. `./.profile.d/` and `~./.Rprofile.d/` to be sourced as `.Rprofile` files.

When done, the `startup` package will be unloaded again leaving no trace of itself.


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
