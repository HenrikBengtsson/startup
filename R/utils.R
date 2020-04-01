stop_if_not <- function(...) {
  res <- list(...)
  n <- length(res)
  if (n == 0L) return()

  for (ii in 1L:n) {
    res_ii <- .subset2(res, ii)
    if (length(res_ii) != 1L || is.na(res_ii) || !res_ii) {
        mc <- match.call()
        call <- deparse(mc[[ii + 1]], width.cutoff = 60L)
        if (length(call) > 1L) call <- paste(call[1L], "...")
        stop(sQuote(call), " is not TRUE", call. = FALSE, domain = NA)
    }
  }
}

eof_ok <- function(file) {
  size <- file.info(file)$size
  ## On Windows, symbolic links give size = 0
  if (.Platform$OS.type == "windows" && size == 0L) size <- 1e9
  bfr <- readBin(file, what = "raw", n = size)
  n <- length(bfr)
  if (n == 0L) return(FALSE)
  is.element(bfr[n], charToRaw("\n\r"))
}

is_dir <- function(f) {
  if (length(f) != 1L) {
    stop(sprintf("INTERNAL ERROR in startup:::is_dir(): only scalar input is supported: [n=%d] %s", length(f), paste(sQuote(f), collapse = ", ")))
  }
  nzchar(f) && file.exists(f) && file.info(f)$isdir
}

is_file <- function(f) {
  if (length(f) != 1L) {
    stop(sprintf("INTERNAL ERROR in startup:::is_file(): only scalar input is supported: [n=%d] %s", length(f), paste(sQuote(f), collapse = ", ")))
  }
  nzchar(f) && file.exists(f) && !file.info(f)$isdir
}

nlines <- function(f) {
  oopts <- options(encoding = "native.enc")
  on.exit(options(oopts))
  bfr <- readLines(f, warn = FALSE)
  bfr <- grep("^[ \t]*#", bfr, value = TRUE, invert = TRUE)
  bfr <- grep("^[ \t]*$", bfr, value = TRUE, invert = TRUE)
  length(bfr)
}

## base::file.size() was only introduced in R 3.2.0
file_size <- function(...) file.info(..., extra_cols = FALSE)$size

path_info <- function(f, extra = NULL) {
  if (!nzchar(f)) return(sQuote(""))
  fx <- path.expand(f)
  if (!is.null(extra)) {
    extra <- paste("; ", extra, sep = "")
  } else {
    extra <- ""
  }

  if (!is_dir(f)) {
    return(sprintf("%s (non-existing directory%s)", sQuote(f), extra))
  }

  if (fx == f) {
    sprintf("%s (existing folder%s)", sQuote(f), extra)
  } else {
    sprintf("%s => %s (existing folder%s)", sQuote(f), sQuote(fx), extra)
  }
}


file_info <- function(f, type = "txt", extra = NULL) {
  if (!nzchar(f)) return(sQuote(""))
  fx <- path.expand(f)
  if (length(extra) > 0L) {
    extra <- paste("; ", extra, sep = "")
  } else {
    extra <- ""
  }
  if (!is_file(f)) {
    return(sprintf("%s (non-existing file%s)", sQuote(f), extra))
  }

  if (fx == f) {
    prefix <- sQuote(f)
  } else {
    prefix <- sprintf("%s => %s", sQuote(f), sQuote(fx))
  }
  if (type == "binary") {
    sprintf("%s (binary file; %d bytes%s)", prefix, file_size(f), extra)
  } else if (type == "env") {
    vars <- names(parse_renviron(f))
    nvars <- length(vars)
    if (nvars > 0) {
      vars <- sprintf(" (%s)", paste(sQuote(vars), collapse = ", "))
    } else {
      vars <- ""
    }
    sprintf("%s (%d lines; %d bytes%s) setting %d environment variables%s",
            prefix, nlines(f), file_size(f), extra, nvars, vars)
  } else if (type == "r") {
    sprintf("%s (%d code lines; %d bytes%s)",
            prefix, nlines(f), file_size(f), extra)
  } else {
    sprintf("%s (%d lines; %d bytes%s)",
            prefix, nlines(f), file_size(f), extra)
  }
}

parse_renviron <- function(f) {
  bfr <- readLines(f, warn = FALSE)
  bfr <- grep("^[ \t]*#", bfr, value = TRUE, invert = TRUE)
  bfr <- grep("^[ \t]*$", bfr, value = TRUE, invert = TRUE)
  bfr <- grep("=.*$", bfr, value = TRUE)
  pattern <- "^([^=]*)[ \t]*=[ \t]*(.*)$"
  bfr <- grep(pattern, bfr, value = TRUE)
  names <- gsub(pattern, "\\1", bfr)
  values <- gsub(pattern, "\\2", bfr)
  names(values) <- names
  values
}

find <- function(what, mode) {
  paths <- search()
  for (pos in seq_along(paths)) {
    if (exists(what, mode = mode, where = pos, inherits = FALSE)) {
      return(structure(pos, names = names(paths)[pos]))
    }
  }
  -1L
}


supports_tcltk <- function() {
  (capabilities("X11") && capabilities("tcltk") &&
   requireNamespace("tcltk") && suppressWarnings(tcltk::.TkUp))
}

tcltk_yesno <- function(question) {
  if (!supports_tcltk()) {
    warning("[startup::startup()]: Your R setup does not support X11 or tcltk dialogs. Because of this, the answer to the question ", sQuote(question), " was defaulted to 'yes'.", call. = FALSE)
    return(TRUE)
  }  
  ans <- tcltk::tk_messageBox("yesno", message = question)
  (ans == "yes")
}

ask_yes_no <- function(question, rdata_workaround = TRUE) {
  ## RStudio Console workarounds?
  if (is_rstudio_console()) {
    if (rdata_workaround) {
      ## WORKAROUND: RStudio Console will load any .RData file as soon as
      ## base::readline() or utils::menu(..., graphics = FALSE) is called
      ## during startup process (https://github.com/rstudio/rstudio/issues/5844)
      ## Instead, we use a TclTk dialog.  If this is not possible, we will
      ## produce a warning and default to 'Yes'.
      return(tcltk_yesno(question))
    }
    
    ## WORKAROUND: RStudio Console does not show the base::readline() prompt
    ## during startup process (https://github.com/rstudio/rstudio/issues/5842)
    readline <- function(prompt) {
      ## Comment: appendLF = FALSE makes no difference. The "readline"
      ## will trigger a "> " prompt to be display on the next line
      message(prompt, appendLF = FALSE)
      base::readline(prompt = "")
    }
  }

  prompt <- sprintf("%s [Y/n]: ", question)
  res <- TRUE
  repeat({
    ans <- readline(prompt)
    ans <- gsub("(^[[:space:]]*|[[:space:]]*$)", "", ans)
    ans <- tolower(ans)
    if (ans %in% c("", "y", "yes")) {
      res <- TRUE
      break
    } else if (ans %in% c("n", "no")) {
      res <- FALSE
      break
    }
  })

  res
}