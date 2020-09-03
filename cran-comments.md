# CRAN submission startup 0.15.0

on 2020-09-03

This submission fixes the problem where the package tests incorrectly attempted to update user's ~/.Rprofile (if it did not have a newline on the last line).  I could reproduce this bug, and then correctness of the bug fix, on the win-builder (release and devel).  I've also verified that this submission does not cause issues for the 1 reverse package dependency available on CRAN.

Thanks in advance


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version | GitHub Actions | Travis CI | AppVeyor CI | Rhub     | Win-builder | Other  |
| --------- | -------------- | --------- | ----------- | -------- | ----------- | ------ |
| 3.2.x     | L              |           |             |          |             |        |
| 3.3.x     | L              |           |             |          |             |        |
| 3.4.x     | L              |           |             |          |             |        |
| 3.5.x     | L              |           |             |          |             |        |
| 3.6.x     | L, M, W        | L, M      |             |          |             |        |
| 4.0.x     | L, M, W        | L, M      | W           |       S  | W           |        |
| devel     | L, M, W        | L         | W (32 & 64) |          | W           |        |

*Legend: OS: L = Linux, S = Solaris, M = macOS, W = Windows.  Architecture: 32 = 32-bit, 64 = 64-bit*
