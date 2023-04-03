# CRAN submission startup 0.20.0

on 2023-04-02

Thanks in advance


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version | GitHub | R-hub  | mac/win-builder |
| --------- | ------ | ------ | --------------- |
| 3.4.x     | L      |        |                 |
| 4.0.x     | L      |        |                 |
| 4.1.x     | L      |        |                 |
| 4.2.x     | L M W  | L M W  | M1 .            |
| devel     | L   W  | L      | M1 .            |

*Legend: OS: L = Linux, M = macOS, M1 = macOS M1, W = Windows*


R-hub checks:

```r
res <- rhub::check(platforms = c(
  "debian-clang-devel", 
  "debian-gcc-patched", 
  "fedora-gcc-devel",
  "macos-highsierra-release-cran",
  "windows-x86_64-release"
))
print(res)
```

gives

```
── startup 0.20.0: OK

  Build ID:   startup_0.20.0.tar.gz-2a464c28284a4baeb307ebbe965446b2
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  5m 37.1s ago
  Build time: 5m 19.1s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.20.0: OK

  Build ID:   startup_0.20.0.tar.gz-76223b23643244a59d3e65b81063c2aa
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  5m 37.1s ago
  Build time: 5m 25s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.20.0: OK

  Build ID:   startup_0.20.0.tar.gz-d7672fc2c5d44ef4aed0091199ace020
  Platform:   Fedora Linux, R-devel, GCC
  Submitted:  5m 37.1s ago
  Build time: 4m 29.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.20.0: OK

  Build ID:   startup_0.20.0.tar.gz-450c81eced1a4351a6b5016491b8c806
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  5m 37.1s ago
  Build time: 2m 33.4s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.20.0: OK

  Build ID:   startup_0.20.0.tar.gz-47e0282f6aab43b1ba74c998f0f537f8
  Platform:   Windows Server 2022, R-release, 32/64 bit
  Submitted:  5m 37.1s ago
  Build time: 1m 56.9s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
