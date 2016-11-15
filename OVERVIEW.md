# startup: Friendly R Startup Configuration

By adding
```r
startup::everything()$unload()
```
to `~/.Rprofile` (or `./.Rprofile`), then all files under (recursively)

1. `./.Renviron.d/` and `~./.Renviron.d/` will be processed as `.Renviron` files.

2. `./.profile.d/` and `~./.Rprofile.d/` will be sourced as `.Rprofile` files.

