# Load .Renviron.d and .Rprofile.d directories during the R startup process

Initiates R using all files under `.Renviron.d/` and / or `.Rprofile.d/`
directories (or in subdirectories thereof).

## Usage

``` r
renviron_d(
  sibling = FALSE,
  all = FALSE,
  unload = FALSE,
  skip = NA,
  dryrun = NA,
  debug = NA,
  paths = NULL
)

rprofile_d(
  sibling = FALSE,
  all = FALSE,
  check = NA,
  unload = FALSE,
  skip = NA,
  on_error = c("error", "warning", "immediate.warning", "message", "ignore"),
  dryrun = NA,
  debug = NA,
  paths = NULL
)

startup(
  sibling = FALSE,
  all = FALSE,
  on_error = c("error", "warning", "immediate.warning", "message", "ignore"),
  keep = c("options"),
  check = NA,
  unload = TRUE,
  skip = NA,
  encoding = getOption("encoding"),
  dryrun = NA,
  debug = dryrun
)
```

## Arguments

- sibling:

  If `TRUE`, then only `.Renviron.d/` and `.Rprofile.d/` directories
  with a sibling `.Renviron` and `.Rprofile` in the same location will
  be considered.

- all:

  If `TRUE`, then *all* `.Renviron.d/` and `.Rprofile.d/` directories
  found on [the R startup search
  path](https://rdrr.io/r/base/Startup.html) are processed, otherwise
  only the *first ones* found.

- unload:

  If `TRUE`, then the package is unloaded afterward, otherwise not.

- skip:

  If `TRUE`, startup directories will be skipped. If `NA`, they will be
  skipped if command-line options `--vanilla`, `--no-init-file`, and /
  or `--no-environ` were specified.

- dryrun:

  If `TRUE`, everything is done except the processing of the startup
  files.

- debug:

  If `TRUE`, debug messages are outputted, otherwise not.

- paths:

  (internal) character vector of directories.

- check:

  If `TRUE`, then the content of startup files are validated.

- on_error:

  Action taken when an error is detected when sourcing an Rprofile file.
  It is not possible to detect error in Renviron files; they are always
  ignored with a message that cannot be captured.

- keep:

  Specify what information should remain after this function complete.
  The default is to keep `startup.session.*` options as recorded by
  [`startup_session_options()`](https://henrikbengtsson.github.io/startup/reference/startup_session_options.md).

- encoding:

  The encodingto use when parsing the R startup files. See
  [`base::parse()`](https://rdrr.io/r/base/parse.html) for more details.

## Details

The above is done in addition the `.Renviron` and `.Rprofile` files that
are supported by the built-in [startup
process](https://rdrr.io/r/base/Startup.html) of R.

## Functions

- `renviron_d()`: Initiate using `.Renviron.d/` files

- `rprofile_d()`: Initiate using `.Rprofile.d/` files

- `startup()`: `renviron_d()` followed by `rprofile_d()` and then the
  package is unloaded

## User-specific installation

In order for `.Rprofile.d` and `.Renviron.d` directories to be included
during the R startup process, a user needs to add `startup::startup()`
to `~/.Rprofile`. Adding this can also be done by calling
[`install()`](https://henrikbengtsson.github.io/startup/reference/install.md)
once.

## Site-wide installation

An alternative to having each user add `startup::startup()` in their own
`~/.Rprofile` file, is to add it to the site-wide `Rprofile.site` file
(see [?Startup](https://rdrr.io/r/base/Startup.html)). The advantage of
such a site-wide installation, is that the users do not have to have a
`.Rprofile` file for `.Rprofile.d` and `.Renviron.d` directories to
work. For this to work for all users automatically, the startup package
should also be installed in the site-wide library.

## Examples

``` r
if (FALSE) { # \dontrun{
# The most common way to use the package is to add
# the following call to the ~/.Rprofile file.
startup::startup()

# To process ~/.Renviron.d/ files, and then any ./.Renviron.d/ files,
# followed by  ~/.Rprofile.d/ files, and then any ./.Rprofile.d/ files,
# add the following call to the ~/.Rprofile file.
startup::startup(all = TRUE)

# For finer control of on exactly what files are used
# functions renviron_d() and rprofile_d() are also available:

# Initiate first .Renviron.d/ found on search path
startup::renviron_d()

# Initiate all .Rprofile.d/ directories found on the startup search path
startup::rprofile_d(all = TRUE)
} # }
```
