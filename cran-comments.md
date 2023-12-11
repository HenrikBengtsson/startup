# CRAN submission startup 0.21.0

on 2023-12-11

Thanks in advance


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version | GitHub | R-hub  | mac/win-builder |
| --------- | ------ | ------ | --------------- |
| 3.6.x     | L      |        |                 |
| 4.1.x     | L      |        |                 |
| 4.2.x     | L      |        |                 |
| 4.3.x     | L M W  | L M W  | M1 W            |
| devel     | L   W  | L      |    W            |

*Legend: OS: L = Linux, M = macOS, M1 = macOS M1, W = Windows*


R-hub checks:

```r
res <- rhub::check(platforms = c(
  "debian-clang-devel", 
  "debian-gcc-patched", 
  "fedora-gcc-devel",
  "windows-x86_64-release"
))
print(res)
```

gives

```
── startup 0.21.0: OK

  Build ID:   startup_0.21.0.tar.gz-ba7d37fcbb004eb98354d4b2bd23e788
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  9m 31.1s ago
  Build time: 4m 48s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.21.0: OK

  Build ID:   startup_0.21.0.tar.gz-47831d7ca2944fdc9ce93bd708599198
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  9m 31.1s ago
  Build time: 4m 34.5s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.21.0: OK

  Build ID:   startup_0.21.0.tar.gz-1aa5a3db5961420bb6abc6cfb46e5eb8
  Platform:   Fedora Linux, R-devel, GCC
  Submitted:  9m 31.1s ago
  Build time: 3m 58.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.21.0: OK

  Build ID:   startup_0.21.0.tar.gz-32adfe106a1f4dda92f53934299935e4
  Platform:   Windows Server 2022, R-release, 32/64 bit
  Submitted:  9m 31.1s ago
  Build time: 4m 3.9s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
