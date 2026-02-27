# Reset all or parts of the "when" cache

Reset all or parts of the "when" cache

## Usage

``` r
reset_when_cache(
  when = c("once", "hourly", "daily", "weekly", "fortnightly", "monthly")
)
```

## Arguments

- when:

  (character vector) Specifies for which "when" frequencies the cache
  should be reset. The default is to reset all of them.

## Value

(invisible) The pathnames of the "when" cache files removed.
