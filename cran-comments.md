# CRAN submission startup 0.16.0

on 2021-11-19

Thanks in advance


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version     | GitHub | R-hub      | mac/win-builder |
| ------------- | ------ | ---------- | --------------- |
| 3.3.x         | L      |            |                 |
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
  "solaris-x86-patched-ods",
  "macos-highsierra-release-cran", "macos-m1-bigsur-release",
  "windows-x86_64-release"))
print(res)
```

gives

```
>  res
── startup 0.16.0: OK

  Build ID:   startup_0.16.0.tar.gz-59de1d347d4d4d6e80e81d143a5831a5
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  3m 22.5s ago
  Build time: 1m 8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.16.0: OK

  Build ID:   startup_0.16.0.tar.gz-416bb27b36844f2ea64095a6ef1d49e4
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  3m 22.5s ago
  Build time: 56.5s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.16.0: OK

  Build ID:   startup_0.16.0.tar.gz-24c3126a2f42471ba0b3969c7a7905c0
  Platform:   CentOS 8, stock R from EPEL
  Submitted:  3m 22.5s ago
  Build time: 1m 2.4s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.16.0: OK

  Build ID:   startup_0.16.0.tar.gz-c04c3d557465498e9669e0938e7ef0fd
  Platform:   Oracle Solaris 10, x86, 32 bit, R release, Oracle Developer Studio 12.6
  Submitted:  3m 22.5s ago
  Build time: 1m 17.3s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.16.0: OK

  Build ID:   startup_0.16.0.tar.gz-2250e37440ab48f29263b747005f1a97
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  3m 22.5s ago
  Build time: 2m 32.8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.16.0: OK

  Build ID:   startup_0.16.0.tar.gz-b6d020c66bef427baa6aa7da97a1d5ac
  Platform:   Apple Silicon (M1), macOS 11.6 Big Sur, R-release
  Submitted:  3m 22.5s ago
  Build time: 46.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── startup 0.16.0: OK

  Build ID:   startup_0.16.0.tar.gz-0f1987dfb89144fea5363242376cef3c
  Platform:   Windows Server 2008 R2 SP1, R-release, 32/64 bit
  Submitted:  3m 22.5s ago
  Build time: 2m 37.8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
