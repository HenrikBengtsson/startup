# Checks whether startup debug is on or not

Checks whether startup debug is on or not

## Usage

``` r
is_debug_on()
```

## Value

Returns `TRUE` if debug is enabled and `FALSE` otherwise.

## Details

The debug mode is when
[`startup()`](https://henrikbengtsson.github.io/startup/reference/startup.md)
is called, either explicitly via argument `debug` or via environment
variable `R_STARTUP_DEBUG`.
