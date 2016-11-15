## Usage

Add
```r
startup::everything()$unload()
```
to `~/.Rprofile` (or `./.Rprofile`).

This will cause all files under (recursively)

1. `./.Renviron.d/` and `~./.Renviron.d/` will be processed as `.Renviron` files.

2. `./.profile.d/` and `~./.Rprofile.d/` will be sourced as `.Rprofile` files.

When done, the `startup` package will be unloaded again.


## Conditional file names

If the name of a file consists of a `<key>=<value>` specification, then that file will only be included / used if the specification is fulfilled on the current system with the current R setup.  For instance, a file `~/.Rprofile.d/os=win` will be ignored unless `startup::sysinfo()$os == "win"`, i.e. the R session is started on a Windows system.

The following `startup::sysinfo()` keys are available for conditional inclusion of files by their file names:

* `interactive` - (logical) whether running interactively or not (as of `interactive()`)
* `nodename`    - (character) the host name (as of `Sys.info()[["nodename"]]`)
* `machine`     - (character) the machine type (as of `Sys.info()[["machine"]]`)
* `os`          - (character) the operating system (as of `.Platform$OS.type`)
* `sysname`     - (character) the system name (as of `Sys.info()[["sysname"]]`)
* `user`        - (character) the user name (as of `Sys.info()[["user"]]`)

To condition on more than one key, separate `<key>=<value>` pairs by commas (`,`), e.g. ``~/.Rprofile.d/work,interactive=TRUE,os=win`.
