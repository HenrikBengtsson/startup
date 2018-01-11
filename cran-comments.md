# CRAN submission startup 0.9.0
on 2018-01-09

## Submission notes

Hi, just my regular follow up on the false negatives in the pre-check:

As with previous submissions, and already known to CRAN, R CMD check
produces NOTEs on hidden directories inst/.Renviron.d and
inst/.Rprofile.d. They were added for a reason and are not mistakes.

Furthermore, with R Under development (unstable) (2018-01-09 r74100), I get:

* checking serialized R objects in the sources ... WARNING
Found file(s) with version 3 serialization:
‘build/vignette.rds’
Such files are only readable in R >= 3.5.0.
Recreate them with R < 3.5.0 or save(version = 2) or saveRDS(version = 2) as appropriate

which I suspect is a false positive.

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
  - R version 3.4.3 (2017-11-30)

* Platform x86_64-apple-darwin15.6.0 (64-bit) [r-hub]:
  - R version 3.4.1 (2017-06-30)

* Platform x86_64-unknown-linux-gnu (64-bit) [Travis CI]:
  - R version 3.3.3 (2017-03-06)
  - R version 3.4.2 (2017-09-28)
  - R Under development (unstable) (2018-01-09 r74100)

* Platform x86_64-pc-linux-gnu (64-bit) [r-hub]:
  - R version 3.4.2 (2017-09-28)
  - R Under development (unstable) (2018-01-07 r74091)

* Platform x86_64-pc-linux-gnu (64-bit):
  - R version 2.14.0 (2011-10-31)
  - R version 2.15.3 (2013-03-01)
  - R version 3.0.0 (2013-04-03)
  - R version 3.1.0 (2014-04-10)
  - R version 3.2.0 (2015-04-16)
  - R version 3.4.3 (2017-11-30)

* Platform i686-pc-linux-gnu (32-bit):
  - R version 3.4.3 (2017-11-30)

* Platform i386-pc-solaris2.10 (32-bit):
  - R version 3.4.1 Patched (2017-07-15 r72924)

* Platform i386-w64-mingw32 (32-bit) [Appveyor CI]:
  - R Under development (unstable) (2017-12-28 r73968)

* Platform x86_64-w64-mingw32/x64 (64-bit) [Appveyor CI]:
  - R version 3.4.3 (2017-11-30)
  - R Under development (unstable) (2017-12-28 r73968)

* Platform x86_64-w64-mingw32/x64 (64-bit) [win-builder]:
  - R version 3.4.3 (2017-11-30)
  - R Under development (unstable) (2018-01-08 r74099)
