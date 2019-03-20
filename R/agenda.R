get_agenda_file <- function(pathname, when = c("hourly", "daily", "weekly", "monthly")) {
  stop_if_not(length(pathname) == 1L, is_file(pathname))
  when <- match.arg(when, choices = c("hourly", "daily", "weekly", "monthly"))
  
  cache_path <- get_os_cache_root_path()
  if (!is_dir(cache_path)) dir.create(cache_path, recursive = TRUE)
  path <- file.path(cache_path, when)
  if (!is_dir(path)) dir.create(path, recursive = TRUE)

  ## Poor-man's file ID
  fi <- file.info(pathname)
  fi <- lapply(fi, FUN = unclass)
  is_numeric <- unlist(lapply(fi, FUN = is.numeric), use.names = FALSE)
  fi <- fi[is_numeric]
  fi <- unlist(fi, use.names = FALSE)
  file_id <- paste(c(basename(pathname), fi), collapse = "-")
  
  agenda_pathname <- file.path(path, file_id)
  attr(agenda_pathname, "pathname") <- pathname
  attr(agenda_pathname, "when") <- when
  
  agenda_pathname
}

is_agenda_file_done <- function(agenda_pathname) {
  if (!is_file(agenda_pathname)) {
    return(structure(FALSE, last_processed = as.POSIXct(NA)))
  }
  when <- attr(agenda_pathname, "when")
  stop_if_not(length(when) == 1L, is.character(when), !is.na(when))
  
  fi <- file.info(agenda_pathname)
  mtime <- fi[["mtime"]]

  res <- FALSE
  
  if (when == "hourly") {
    mtime_hour <- as.integer(format(mtime, format = "%H"))
    this_hour <- as.integer(format(Sys.time(), format = "%H"))
    res <- (mtime_hour >= this_hour)
  } else if (when == "daily") {
    ## Compare using the local time zone
    mtime_date <- as.Date(mtime, tz = Sys.timezone())
    this_date <- Sys.Date()
    res <- (mtime_date >= this_date)
  } else if (when == "weekly") {
    mtime_week <- as.integer(format(mtime, format = "%V"))
    this_date <- Sys.Date()
    this_week <- as.integer(format(this_date, format = "%V"))
    res <- (mtime_week >= this_week)
  } else if (when == "monthly") {
    mtime_month <- as.integer(format(mtime, format = "%m"))
    this_date <- Sys.Date()
    this_month <- as.integer(format(this_date, format = "%m"))
    res <- (mtime_month >= this_month)
  } else {
    stop("Unknown value on argument 'when': ", sQuote(when))
  }

  attr(res, "last_processed") <- mtime
  
  res
}

mark_agenda_file_done <- function(agenda_pathname) {
  pathname <- attr(agenda_pathname, "pathname")
  timestamp <- format(Sys.time(), format = "%Y-%m-%d %H:%M:%OS3 %z")
  cat(file = agenda_pathname, pathname, "\n", timestamp, "\n", sep = "")
  agenda_pathname
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
  when <- intersect(when, c("hourly", "daily", "weekly", "monthly"))

  when
}
