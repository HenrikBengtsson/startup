# CRAN submission startup 0.14.1

on 2020-03-31

I've verified that this submission does not cause issues for the 1 reverse package dependency available on CRAN and Bioconductor.

Thanks in advance


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version   | GitHub Actions | Travis CI | AppVeyor CI | Rhub      | Win-builder | Other  |
| ----------- | -------------- | --------- | ----------- | --------- | ----------- | ------ |
| 2.14.0      |                |           |             |           |             | L      |
| 3.2.5       | L              |           |             |           |             |        |
| 3.3.3       | L              |           |             |           |             |        |
| 3.4.4       | L              |           |             |           |             | L (32) |
| 3.5.3       | L, M, W        | L, M      |             |           |             |        |
| 3.6.1       |                |           |             | L         |             |        |
| 3.6.3       | L, M, W        | L, M      | W           |    S (32) | W           | L (32) |
| 4.0.0-alpha |    M           | L         |             | L     W   | W           |        |
| devel       |       W        |           | W (32 & 64) |           |             |        |

*Legend: OS: L = Linux, S = Solaris, M = macOS, W = Windows.  Architecture: 32 = 32-bit, 64 = 64-bit*
