backup <- function(file, quiet = FALSE) {
  ## base::file.size() was only introduced in R 3.2.0
  file_size <- function(...) file.info(..., extra_cols = FALSE)$size

  if (quiet) notef <- function(...) NULL

  stopifnot(file.exists(file))
  timestamp <- format(Sys.time(), "%Y%m%d-%H%M%S")
  file_backup <- sprintf("%s.bak.%s", file, timestamp)
  file.copy(file, file_backup)
  size <- file_size(file)
  backup_size <- file_size(file_backup)
  notef("Backed up R startup file: %s -> %s (%d bytes)",
        sQuote(file), sQuote(file_backup), size)
  stopifnot(file.exists(file_backup), identical(backup_size, size))
  file_backup
}
