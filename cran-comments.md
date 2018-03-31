# CRAN submission startup 0.10.0
on 2018-03-26

## Submission notes

Thanks in advance


## Reply to "CRAN teams' auto-check service"

Hi, just my regular follow up on the false negatives in the pre-check:

As with previous submissions, and already known to CRAN, R CMD check
produces NOTEs on hidden directories inst/.Renviron.d and
inst/.Rprofile.d. They were added for a reason and are not mistakes.

All the best


## Notes not sent to CRAN

### R CMD check --as-cran validation

The package has been verified using `R CMD check --as-cran` on:

* Platform x86_64-apple-darwin13.4.0 (64-bit) [Travis CI]:
  - R version 3.3.2 (2016-10-31)

* Platform x86_64-apple-darwin15.6.0 (64-bit) [Travis CI]:
  - R version 3.4.4 (2018-03-15)

* Platform x86_64-apple-darwin15.6.0 (64-bit) [r-hub]:
  - R version 3.3.3 (2017-03-06)
  - R version 3.4.4 (2018-03-15)

* Platform x86_64-unknown-linux-gnu (64-bit) [Travis CI]:
  - R version 3.3.3 (2017-03-06)
  - R version 3.4.4 (2017-01-27) [sic!]
  - R Under development (unstable) (2018-03-26 r74468)

* Platform x86_64-pc-linux-gnu (64-bit) [r-hub]:
  - R version 3.4.4 (2018-03-15)
  - R Under development (unstable) (2018-01-07 r74091)

* Platform x86_64-pc-linux-gnu (64-bit):
  - R version 2.14.0 (2011-10-31)
  - R version 2.15.3 (2013-03-01)
  - R version 3.0.0 (2013-04-03)
  - R version 3.1.1 (2014-07-10)
  - R version 3.2.0 (2015-04-16)
  - R version 3.4.4 (2018-03-15)

* Platform i686-pc-linux-gnu (32-bit):
  - R version 3.4.4 (2018-03-15)

* Platform i386-pc-solaris2.10 (32-bit): [r-hub]
  - R version 3.4.1 Patched (2017-07-15 r72924)

* Platform x86_64-w64-mingw32 (64-bit) [r-hub]:
  - R Under development (unstable) (2018-03-22 r74446)

* Platform i386-w64-mingw32 (32-bit) [Appveyor CI]:
  - R Under development (unstable) (2018-03-25 r74463)

* Platform x86_64-w64-mingw32/x64 (64-bit) [Appveyor CI]:
  - R version 3.4.4 (2018-03-15)
  - R Under development (unstable) (2018-03-25 r74463)

* Platform x86_64-w64-mingw32/x64 (64-bit) [win-builder]:
  - R version 3.4.4 (2018-03-15)
  - R Under development (unstable) (2018-03-23 r74448)
