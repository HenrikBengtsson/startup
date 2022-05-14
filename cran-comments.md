# CRAN submission startup 0.18.0

on 2022-05-13

Thanks in advance


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version | GitHub | R-hub    | mac/win-builder |
| --------- | ------ | -------- | --------------- |
| 3.4.x     | L      |          |                 |
| 4.0.x     | L      |          |                 |
| 4.1.x     | L      |          |                 |
| 4.2.x     | L M W  | L M M1 W | M1 W            |
| devel     | L M W  | L        |    W            |

*Legend: OS: L = Linux, M = macOS, M1 = macOS M1, W = Windows*


R-hub checks:

```r
res <- rhub::check(platform = c(
  "debian-clang-devel", "debian-gcc-patched", "linux-x86_64-centos-epel",
  "macos-highsierra-release-cran", "macos-m1-bigsur-release",
  "windows-x86_64-release"))
print(res)
```

gives

```
── startup 0.18.0: OK

  Build ID:   startup_0.18.0.tar.gz-810c4dc794ed4940baacc9333e2dbd35
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  10m 44.9s ago
  Build time: 1m 28.8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.18.0: OK

  Build ID:   startup_0.18.0.tar.gz-17910cdc047f4926b353340e66fd2b24
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  10m 45s ago
  Build time: 1m 24.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.18.0: OK

  Build ID:   startup_0.18.0.tar.gz-8a5789dbe13a460d8f1a2fc24add5f94
  Platform:   CentOS 8, stock R from EPEL
  Submitted:  10m 45s ago
  Build time: 1m 24.2s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.18.0: OK

  Build ID:   startup_0.18.0.tar.gz-dee7cbaa23a048ecb965b95f7fcc1b94
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  10m 45s ago
  Build time: 1m 7.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.18.0: OK

  Build ID:   startup_0.18.0.tar.gz-7cd4d4232bc244d0a48cbe6a2a222d67
  Platform:   Apple Silicon (M1), macOS 11.6 Big Sur, R-release
  Submitted:  10m 45.1s ago
  Build time: 46s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.18.0: OK

  Build ID:   startup_0.18.0.tar.gz-f1cb9b63535242678e6cc3b95eb21331
  Platform:   Windows Server 2008 R2 SP1, R-release, 32/64 bit
  Submitted:  10m 45.1s ago
  Build time: 2m 30.5s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
