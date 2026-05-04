# Check for and fix common mistakes in .Rprofile

Check for and fix common mistakes in `.Rprofile` files.

## Usage

``` r
check(all = FALSE, fix = TRUE, backup = TRUE, debug = FALSE)
```

## Arguments

- all:

  Should all or only the first entry on [the R startup search
  path](https://rdrr.io/r/base/Startup.html) be checked?

- fix:

  If `TRUE`, an attempt will be made to automatically fix detected
  issues, otherwise not.

- backup:

  If `TRUE`, a timestamped backup copy of the original file is created
  before modifying it, otherwise not.

- debug:

  If `TRUE`, debug messages are output, otherwise not.

## Value

Invisibly returns a character vector of files that were "fixed"
(modified), if any. If no files needed to be fixed, or `fix = FALSE`,
then an empty vector is returned.

## References

1.  R-devel thread 'Last line in .Rprofile must have newline (PR#4056)',
    2003-09-03,
    <https://stat.ethz.ch/pipermail/r-devel/2003-September/027457.html>
