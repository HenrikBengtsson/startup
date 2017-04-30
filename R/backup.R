backup <- function(file) {
  ## base::file.size() was only introduced in R 3.2.0
  file_size <- function(...) file.info(..., extra_cols = FALSE)$size
    
  stopifnot(file.exists(file))
  timestamp <- format(Sys.time(), "%Y%m%d-%H%M%S")
  file_backup <- sprintf("%s.bak.%s", file, timestamp)
  file.copy(file, file_backup)
  size <- file_size(file)
  backup_size <- file_size(file_backup)
  logf("Backed up R startup file: %s (%d bytes) -> %s (%d bytes)",
       sQuote(file), size, sQuote(file_backup), backup_size)
  stopifnot(file.exists(file_backup), identical(backup_size, size))
  file_backup
}
