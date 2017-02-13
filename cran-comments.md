# CRAN submission startup 0.5.0
on 2017-02-12

As with previous submissions, and already known to CRAN,
R CMD check gives the below NOTE on hidden directories. These
were added to the package on purpose and not mistakes.

* checking for hidden files and directories ... NOTE
Found the following hidden files and directories:
  inst/.Renviron.d
  inst/.Rprofile.d
These were most likely included in error. See section ‘Package
structure’ in the ‘Writing R Extensions’ manual.

Thanks in advance


## Notes not sent to CRAN
The package has been verified using `R CMD check --as-cran` on:

* Platform x86_64-apple-darwin13.4.0 (64-bit) [Travis CI]:
  - R 3.2.4 Revised (2016-03-16)
  - R version 3.3.2 (2016-10-31)
  
* Platform x86_64-unknown-linux-gnu (64-bit) [Travis CI]:
  - R version 3.2.5 (2016-04-14)
  - R version 3.3.2 (2016-10-31)
  - R Under development (unstable) (2017-02-12 r72160)
  
* Platform x86_64-pc-linux-gnu (64-bit):
  - R version 3.3.2 (2016-10-31)

* Platform x86_64-pc-linux-gnu (64-bit) [r-hub]:
  - R version 3.3.2 (2016-10-31)

* Platform i686-pc-linux-gnu (32-bit):
  - R version 3.3.2 (2016-10-31)

* Platform i386-w64-mingw32 (32-bit) [Appveyor CI]:
  - R Under development (unstable) (2017-02-10 r72157)

* Platform x86_64-w64-mingw32/x64 (64-bit) [Appveyor CI]:
  - R version 3.3.2 (2016-10-31)
  - R Under development (unstable) (2017-02-10 r72157)

* Platform x86_64-w64-mingw32 (64-bit) [r-hub]:
  - R Under development (unstable) (2017-01-24 r72026)

* Platform x86_64-w64-mingw32/x64 (64-bit) [win-builder]:
  - R version 3.3.2 (2016-10-31)
  - R Under development (unstable) (2017-02-10 r72157)
