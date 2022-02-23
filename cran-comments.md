# CRAN submission startup 0.17.0

on 2022-02-23

Thanks in advance


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version     | GitHub | R-hub      | mac/win-builder |
| ------------- | ------ | ---------- | --------------- |
| 3.4.x         | L      |            |                 |
| 3.5.x         | L      |            |                 |
| 4.0.x         | L      | L          |                 |
| 4.1.x         | L M W  | L M M1 S W | M1 W            |
| devel         | L M W  | L          |    W            |

*Legend: OS: L = Linux, S = Solaris, M = macOS, M1 = macOS M1, W = Windows*


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
── startup 0.17.0: OK

  Build ID:   startup_0.17.0.tar.gz-457d776a96434379aab308a42a44e8db
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  6m 56.8s ago
  Build time: 1m 19.5s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.17.0: OK

  Build ID:   startup_0.17.0.tar.gz-20fb17d014de4b20909dc9e4e02e4c72
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  6m 56.8s ago
  Build time: 1m 3.8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.17.0: OK

  Build ID:   startup_0.17.0.tar.gz-b8e6aedececc41899df17f0751eef45e
  Platform:   CentOS 8, stock R from EPEL
  Submitted:  6m 56.8s ago
  Build time: 1m 15.2s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.17.0: OK

  Build ID:   startup_0.17.0.tar.gz-afc468a68bee4ffa9f8d77de400469eb
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  6m 56.8s ago
  Build time: 1m 14.9s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.17.0: OK

  Build ID:   startup_0.17.0.tar.gz-5ad0f53a7f0d48579e3696fcf9f75a9b
  Platform:   Apple Silicon (M1), macOS 11.6 Big Sur, R-release
  Submitted:  6m 56.8s ago
  Build time: 43.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.17.0: OK

  Build ID:   startup_0.17.0.tar.gz-6cc9220d3117445e83204c433851d8d6
  Platform:   Windows Server 2008 R2 SP1, R-release, 32/64 bit
  Submitted:  6m 56.8s ago
  Build time: 2m 38.7s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
