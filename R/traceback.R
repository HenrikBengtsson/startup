find_source_traceback <- function() {
  # Identify the environment/frame of interest by making sure
  # it at least contains all the arguments of source().
  argsToFind <- names(formals(base::source))

  # Scan the call frames/environments backwards...
  srcfileList <- list()
  for (ff in sys.nframe():0) {
    env <- sys.frame(ff)

    # Does the environment look like a source() environment?
    exist <- sapply(argsToFind, FUN=exists, envir=env, inherits=FALSE)
    if (!all(exist)) {
      # Nope, then skip to the next one
      next
    }

    # Identity the source file
    if (exists("srcfile", envir=env, inherits=FALSE)) {
      srcfile <- get("srcfile", envir=env, inherits=FALSE)
    } else {
      ## AD HOC: Needed when for instance 'XML' is attached
      srcfile <- get("srcfile", envir=env, inherits=TRUE)
      ## Failed?
      if (!inherits(srcfile, "srcfile")) srcfile <- NULL
    }
    
    if (!is.null(srcfile)) {
      if (!is.function(srcfile)) {
        srcfileList <- c(srcfileList, list(srcfile))
      }
    }
  } # for (ff ...)

  # Extract the pathnames to the files called
  pathnames <- sapply(srcfileList, FUN=function(srcfile) {
    if (inherits(srcfile, "srcfile")) {
      pathname <- srcfile$filename
    } else if (is.environment(srcfile)) {
      pathname <- srcfile$filename
    } else if (is.character(srcfile)) {
      # Occurs with source(..., keep.source=FALSE)
      pathname <- srcfile
    } else {
      pathname <- NA_character_
      warning("Unknown class of 'srcfile': ", class(srcfile)[1L])
    }
    pathname
  })
  names(srcfileList) <- pathnames

  srcfileList
}
