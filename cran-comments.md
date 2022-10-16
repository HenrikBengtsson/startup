# CRAN submission startup 0.19.0

on 2022-10-15

Thanks in advance


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version | GitHub | R-hub  | mac/win-builder |
| --------- | ------ | ------ | --------------- |
| 3.4.x     | L      |        |                 |
| 3.6.x     | L      |        |                 |
| 4.0.x     | L      |        |                 |
| 4.1.x     | L      |        |                 |
| 4.2.x     | L M W  | L M W  | M1 .            |
| devel     | L M W  | L      |    .            |

*Legend: OS: L = Linux, M = macOS, M1 = macOS M1, W = Windows*


R-hub checks:

```r
res <- rhub::check(platforms = c(
  "debian-clang-devel",
  "debian-gcc-patched",
  "macos-highsierra-release-cran",
  ## "macos-m1-bigsur-release",
  "windows-x86_64-release"))
print(res)
```

gives

```
── startup 0.19.0: OK

  Build ID:   startup_0.19.0.tar.gz-4aaadc2fb9664c5aaaea84f88ef22811
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  5m 25.3s ago
  Build time: 2m 51s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.19.0: OK

  Build ID:   startup_0.19.0.tar.gz-3ae99afd2f744e1f9699a56ba9e86f67
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  5m 25.3s ago
  Build time: 2m 51.2s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.19.0: OK

  Build ID:   startup_0.19.0.tar.gz-90cf4e134b6a45ae8cda479e9b316b75
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  5m 25.3s ago
  Build time: 1m 47.5s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.19.0: OK

  Build ID:   startup_0.19.0.tar.gz-8aa43c73b26f426b86268390c1e2a04f
  Platform:   Windows Server 2022, R-release, 32/64 bit
  Submitted:  9m 41.6s ago
  Build time: 8m 3.8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
