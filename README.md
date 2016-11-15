# startup: Friendly R Startup Configuration

By adding
```r
startup::everything()$unload()
```
to `~/.Rprofile` (or `./.Rprofile`), then all files under (recursively)

1. `./.Renviron.d/` and `~./.Renviron.d/` will be processed as `.Renviron` files.

2. `./.profile.d/` and `~./.Rprofile.d/` will be sourced as `.Rprofile` files.

and at the end the `startup` package will be unloaded.


## Installation
R package startup is only available via [GitHub](https://github.com/HenrikBengtsson/startup) and can be installed in R as:
```r
source('http://callr.org/install#HenrikBengtsson/startup')
```




## Software status

| Resource:     | GitHub        | Travis CI       | Appveyor         |
| ------------- | ------------------- | --------------- | ---------------- |
| _Platforms:_  | _Multiple_          | _Linux & macOS_ | _Windows_        |
| R CMD check   |  | <a href="https://travis-ci.org/HenrikBengtsson/startup"><img src="https://travis-ci.org/HenrikBengtsson/startup.svg" alt="Build status"></a>   | <a href="https://ci.appveyor.com/project/HenrikBengtsson/startup"><img src="https://ci.appveyor.com/api/projects/status/github/HenrikBengtsson/startup?svg=true" alt="Build status"></a> |
| Test coverage |                     | <a href="https://codecov.io/gh/HenrikBengtsson/startup"><img src="https://codecov.io/gh/HenrikBengtsson/startup/branch/develop/graph/badge.svg" alt="Coverage Status"/></a>     |                  |
