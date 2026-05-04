# Options and environment variables used by the 'startup' package

Below are environment variables and R options that are used by the
startup package. The `R_STARTUP_***` environment variables must be set
before calling the
[`startup::startup()`](https://henrikbengtsson.github.io/startup/reference/startup.md)
function, that is, either (i) prior to launching R or (ii) in the
`.Renviron` file.

## Controls whether startup is used or not

- `R_STARTUP_DISABLE` / startup.disable::

  (logical) If `TRUE`,
  [`startup::startup()`](https://henrikbengtsson.github.io/startup/reference/startup.md)
  is fully disabled such that *no* `.Renviron.d/` or `.Rprofile.d/`
  files are processed. *Note*: Files `.Renviron` and `.Rprofile` are
  still processed because these are outside the control of the startup
  package. (Default: `FALSE`)

- `R_STARTUP_DRYRUN` / startup.dryrun::

  (logical) Controls the default value of argument `dryrun` of
  [`startup()`](https://henrikbengtsson.github.io/startup/reference/startup.md).
  (Default: `FALSE`)

## Additional customization of the startup process

- `R_STARTUP_FILE` / startup.file::

  (R script as a character string) Optional R script that is parsed and
  evaluated after `.Renviron.d/` and `.Rprofile.d/` files, and
  `R_STARTUP_INIT` code, have been processed, e.g.
  `R_STARTUP_FILE="setup.R" R --quiet`. (Default: not specified)

- `R_STARTUP_INIT` / startup.init::

  (R code as a character string) Optional R code that is parsed and
  evaluated after `.Renviron.d/` and `.Rprofile.d/` files, but before
  `R_STARTUP_FILE` code, have been processed e.g.
  `R_STARTUP_INIT="message('Hello world')" R --quiet`. The specified
  string must be parsable by
  [`base::parse()`](https://rdrr.io/r/base/parse.html). (Default: not
  specified)

- `R_STARTUP_RDATA` / startup.rdata::

  (comma-separated values) Controls whether an existing `./.RData` file
  should be processed or not. If `"remove"`, it will be skipped by
  automatically removing it. If `"rename"`, it will be renamed to
  `./.RData.YYYYMMDD_hhmmss` where the timestamp is the last time the
  file was modified. If `"prompt"`, the user is prompted whether they
  want to load the file or rename it. In non-interactive session,
  `"prompt"` will fallback to loading the content (default). To fallback
  to renaming the file, use `"prompt,rename"`. If `"warn"`, a warning
  will be produced, but content is still loaded. Note that in contrast
  to `R` and `R CMD BATCH file.R`, `Rscript` does *not* load `.RData`
  files unless command-line option `--restore` is specified. (Default:
  not specified)

## Controls what validation checks are performed at startup

- `R_STARTUP_CHECK` / startup.check::

  (logical) Controls the default value of argument `check` of
  [`startup()`](https://henrikbengtsson.github.io/startup/reference/startup.md).
  (Default: `TRUE`)

- `R_STARTUP_CHECK_OPTIONS_IGNORE` / startup.check.options.ignore::

  (character vector or comma-separated character string) Names of R
  options that should *not* be validated at the end of the
  [`startup()`](https://henrikbengtsson.github.io/startup/reference/startup.md)
  process. (Default: `"error"`)

## Settings useful for debugging and prototyping

- `R_STARTUP_DEBUG` / startup.debug::

  (logical) Controls the default value of argument `debug` of
  [`startup()`](https://henrikbengtsson.github.io/startup/reference/startup.md).
  (Default: `FALSE`)

- `R_STARTUP_DEBUG_FILE` / startup.debug.file::

  (character string or NULL) Controls where
  [`startup()`](https://henrikbengtsson.github.io/startup/reference/startup.md)
  debug messages are output. If set, it specifies the file where debug
  messages are written to. If file already exists, it is overwritten.
  Unless an absolute filename is given, the location of the file is
  relative to the working directory where R was started. If the filename
  comprises the string `{{pid}}`, it is replaced by the R process'
  process identifier (PID) per
  [`Sys.getpid()`](https://rdrr.io/r/base/Sys.getpid.html). If `NULL` or
  `<message>`, then debug messages are output using the
  [`message()`](https://rdrr.io/r/base/message.html) function. (Default:
  not specified)

- startup.commandArgs::

  (character vector) Overrides the command-line arguments that
  [`startup()`](https://henrikbengtsson.github.io/startup/reference/startup.md)
  uses, which can be useful to prototype and test alternative ways that
  R might be launched. (Default:
  [`base::commandArgs()`](https://rdrr.io/r/base/commandArgs.html))

- `R_STARTUP_TIME` / startup.time::

  (POSIX timestamp; character string) Overrides the current timestamp,
  which can be useful to prototype and test functionalities that depend
  on the current time, e.g. inclusion and exclusion of files based on
  `when=<periodicity>` tags. The specified string must be parsable by
  [`base::as.POSIXct()`](https://rdrr.io/r/base/as.POSIXlt.html).
  (Default: not specified)
