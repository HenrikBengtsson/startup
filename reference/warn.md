# Produce a warning

Produce a warning

## Usage

``` r
warn(..., call. = FALSE, immediate. = TRUE, domain = NULL)
```

## Arguments

- ..., domain:

  The message and optionally the domain used for translation. The ...
  arguments are passed to
  [base::sprintf](https://rdrr.io/r/base/sprintf.html) to create the
  message string.

- call.:

  If [base::TRUE](https://rdrr.io/r/base/logical.html), the call is
  included in the warning message, otherwise not.

- immediate.:

  If [base::TRUE](https://rdrr.io/r/base/logical.html), the warning is
  outputted immediately, otherwise not.
