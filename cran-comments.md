# CRAN submission startup 0.7.0
on 2017-09-04

As with previous submissions, and already known to CRAN,
R CMD check produces NOTEs on hidden directories inst/.Renviron.d
and inst/.Rprofile.d. They were added for a reason and are not mistakes.

Thanks in advance


## Reply to "CRAN teams' auto-check service"

Hi, just following up on the false negatives in the pre-check:

As with previous submissions, and already known to CRAN, R CMD check
produces NOTEs on hidden directories inst/.Renviron.d and
inst/.Rprofile.d. They were added for a reason and are not mistakes.

Thanks in advance


### R CMD check --as-cran validation

The package has been verified using `R CMD check --as-cran` on:

* Platform x86_64-apple-darwin13.4.0 (64-bit) [Travis CI]:
  - R version 3.3.2 (2016-10-31)
  - R version 3.4.1 (2017-06-30)
  
* Platform x86_64-unknown-linux-gnu (64-bit) [Travis CI]:
  - R version 3.3.3 (2017-03-06)
  - R version 3.4.1 (2017-06-30)
  - R Under development (unstable) (2017-09-04 r73202)

* Platform x86_64-pc-linux-gnu (64-bit) [r-hub]:
  - R version 3.4.1 (2017-06-30)
  - R Under development (unstable) (2017-09-02 r73195)

* Platform x86_64-pc-linux-gnu (64-bit):
  - R version 2.14.0 (2011-10-31)
  - R version 3.0.0 (2013-04-03)
  - R version 3.0.1 (2013-05-16)
  - R version 3.0.2 (2013-09-25)
  - R version 3.2.0 (2015-04-16)
  - R version 3.4.1 (2017-06-30)

* Platform i686-pc-linux-gnu (32-bit):
  - R version 3.4.1 (2017-06-30)

* Platform i386-w64-mingw32 (32-bit) [Appveyor CI]:
  - R Under development (unstable) (2017-09-02 r73196)

* Platform x86_64-w64-mingw32/x64 (64-bit) [Appveyor CI]:
  - R version 3.4.1 (2017-06-30)
  - R Under development (unstable) (2017-09-02 r73196)

* Platform x86_64-w64-mingw32/x64 (64-bit) [win-builder]:
  - R version 3.4.1 (2017-06-30)
  - R Under development (unstable) (2017-09-02 r73196)
