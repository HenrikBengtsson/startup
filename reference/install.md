# Install and uninstall support for .Renviron.d and .Rprofile.d startup directories

Install and uninstall support for `.Renviron.d` and `.Rprofile.d`
startup directories by appending / removing one line of code to the
`~/.Rprofile` file.

## Usage

``` r
install(
  file = rprofile_user(),
  backup = TRUE,
  overwrite = FALSE,
  path = dirname(file),
  make_dirs = TRUE,
  quiet = FALSE
)

uninstall(file = rprofile_user(), backup = TRUE, quiet = FALSE)
```

## Arguments

- file:

  The pathname where to create or update the `.Rprofile` file.

- backup:

  If `TRUE`, a timestamped backup copy of the original file is created
  before modifying / overwriting it, otherwise not. If the backup fails,
  then an error is produced and the R startup file is unmodified.

- overwrite:

  If the R startup file already exist, then `FALSE` (default) appends
  the startup code to the end of the file. is overwritten. If `TRUE`,
  any pre-existing R startup file is overwritten.

- path:

  The folder where to create `.Renviron.d` and `.Rprofile.d` directory.

- make_dirs:

  If `TRUE` (default), directories `.Renviron.d/` and `.Rprofile.d/` are
  created in folder `path`, if missing.

- quiet:

  If `FALSE` (default), detailed messages are generated, otherwise not.

## Value

The pathname of the R startup file modified.

## Functions

- `install()`: injects a `tryCatch(startup::startup(), ...)` call to the
  `.Rprofile` file, which is created if missing.

- `uninstall()`: Remove calls to [`startup::startup()`](startup.md) and
  similar.
