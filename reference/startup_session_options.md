# Record R session information as options

Record R session information as options

## Usage

``` r
startup_session_options(action = c("update", "overwrite", "erase"))
```

## Arguments

- action:

  If `"update"` or `"overwrite"`, R options `"startup.session.*"` are
  set. If `"update"`, then such options that are not already set are
  updated. If `"erase"`, any existing `"startup.session.*"` options are
  removed.

## Value

Returns invisibly a named list of the options prefixed
`"startup.session."`:

- `startup.session.startdir`:

  (character) the working directory when the startup was first loaded.
  If
  [`startup::startup()`](https://henrikbengtsson.github.io/startup/reference/startup.md)
  is called at the very beginning of the `.Rprofile` file, this is also
  the directory that the current R session was launched from.

- `startup.session.starttime`:

  (POSIXct) the time when the startup was first loaded.

- `startup.session.id`:

  (character) a unique ID for the current R session.

- `startup.session.dumpto`:

  (character) a session-specific name that can be used for argument
  `dumpto` of [dump.frames()](https://rdrr.io/r/utils/debugger.html)
  (also for dumping to file).

## Examples

``` r
opts <- startup::startup_session_options()
opts
#> $startup.session.startdir
#> [1] "/tmp/hb/Rtmp7K7aPI/startup"
#> 
#> $startup.session.starttime
#> [1] "2026-05-04 09:10:22 PDT"
#> 
#> $startup.session.starttime_iso
#> [1] "20260504-091022"
#> 
#> $startup.session.id
#> [1] "RtmpdWLMKy"
#> 
#> $startup.session.dumpto
#> [1] "/tmp/hb/Rtmp7K7aPI/startup/last.dump_20260504-091022_RtmpdWLMKy"
#> 
```
