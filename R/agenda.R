get_startup_time <- local({
  now <- NULL
  
  function() {
    if (is.null(now)) {
      time <- Sys.getenv("R_STARTUP_TIME", "")
      if (nzchar(time)) {
        now <<- tryCatch({
	  as.POSIXct(time)
	}, error = function(ex) {
	  warning("Failed to parse 'R_STARTUP_TIME' as a timestamp: ",
	          sQuote(time), ". The reason was: ", conditionMessage(ex))
           NULL
	})
      }
      if (is.null(now)) {
        now <<- Sys.time()
      }
    }
    now
  }
})

get_when_path <- function(when) {
  when <- match.arg(when, choices = known_when_keys, several.ok = TRUE)
  
  cache_path <- get_os_cache_root_path()
  if (!is_dir(cache_path)) dir.create(cache_path, recursive = TRUE)
  path <- file.path(cache_path, when)
  path
}

get_when_file <- function(pathname, when) {
  stop_if_not(length(pathname) == 1L, is_file(pathname))
  when <- match.arg(when, choices = known_when_keys)
  
  path <- get_when_path(when = when)
  if (!is_dir(path)) dir.create(path, recursive = TRUE)

  ## Poor-man's file ID
  fi <- file.info(pathname)
  fi <- lapply(fi, FUN = unclass)
  is_numeric <- unlist(lapply(fi, FUN = is.numeric), use.names = FALSE)
  fi <- fi[is_numeric]
  fi <- unlist(fi, use.names = FALSE)
  file_id <- paste(c(basename(pathname), fi), collapse = "-")
  
  when_pathname <- file.path(path, file_id)
  attr(when_pathname, "pathname") <- pathname
  attr(when_pathname, "when") <- when
  
  when_pathname
}

is_when_file_done <- function(when_pathname) {
  if (!is_file(when_pathname)) {
    return(structure(FALSE, last_processed = as.POSIXct(NA)))
  }
  when <- attr(when_pathname, "when")
  stop_if_not(length(when) == 1L, is.character(when), !is.na(when))
  
  fi <- file.info(when_pathname)
  mtime <- fi[["mtime"]]

  done <- NA
  
  if (when == "once") {
    format <- "%t"  ## Trick to produce equal output
  } else if (when == "hourly") {
    format <- "%Y-%m-%d %H"
  } else if (when == "daily") {
    format <- "%Y-%m-%d"
  } else if (when == "weekly") {
    format <- "%Y %V"
  } else if (when == "fortnightly") {
    format <- "%Y %V"
    now_time <- get_startup_time()
    last_year <- format(mtime, format = "%Y")
    last_week <- as.integer(format(mtime, format = "%V"))
    last_fortnight <- floor(last_week / 2)
    now_year <- format(now_time, format = "%Y")
    now_week <- as.integer(format(now_time, format = "%V"))
    now_fortnight <- floor(now_week / 2)
    last <- sprintf("%s %02d", last_year, last_fortnight)
    now <- sprintf("%s %02d", now_year, now_fortnight)
    done <- (last >= now)
##    R.utils::mstr(list(pathname = attr(when_pathname, "pathname"), when = when, last = last, now = now, done = done))
  } else if (when == "monthly") {
    format <- "%Y %m"
  } else {
    stop("Unknown value on argument 'when': ", sQuote(when))
  }

  if (is.na(done)) {
    last <- format(mtime, format = format)
    now <- format(get_startup_time(), format = format)
    done <- (last >= now)
##    R.utils::mstr(list(pathname = attr(when_pathname, "pathname"), when = when, last = last, now = now, done = done))
  }

  attr(done, "last_processed") <- mtime
  
  done
}

mark_when_file_done <- function(when_pathname) {
  pathname <- attr(when_pathname, "pathname")
  timestamp <- format(get_startup_time(), format = "%Y-%m-%d %H:%M:%OS3 %z")
  cat(file = when_pathname, pathname, "\n", timestamp, "\n", sep = "")
  when_pathname
}


get_when <- function(pathname) {
  stop_if_not(length(pathname) == 1L, is.character(pathname), !is.na(pathname))

  ## Identify files specifying this <key>=<value>
  op <- "="
  pattern <- sprintf(".*[^a-z]*(when)%s([^=,/]*).*", op)
  if (!grepl(pattern, pathname, fixed = FALSE)) return(character(0L))

  pathname <- gsub("[.](r|R)$", "", pathname)
  file <- unlist(strsplit(pathname, split = "[,/]", fixed = FALSE), use.names = FALSE)
  
  when <- gsub(pattern, "\\2", file)

  ## Keep unique 'when' conditions
  when <- unique(when)
  
  ## Drop unknown 'when' conditions
  when <- intersect(when, known_when_keys)

  when
}


reset_when <- function(when = c("once", "hourly", "daily", "weekly", "fortnightly", "monthly")) {
  paths <- get_when_path(when = when)
  exists <- vapply(paths, FUN = is_dir, FUN.VALUE = FALSE)
  paths <- paths[exists]
  pathnames <- dir(paths, full.names = TRUE, all.files = TRUE, include.dirs = TRUE, no.. = TRUE)
  for (path in paths) unlink(path, recursive = TRUE)
  invisible(pathnames)
}

known_when_keys <- eval(formals(reset_when)[["when"]])
