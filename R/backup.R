backup <- function(file) {
  stopifnot(file.exists(file))
  timestamp <- format(Sys.time(), "%Y%m%d-%H%M%S")
  file_backup <- sprintf("%s.bak.%s", file, timestamp)
  file.copy(file, file_backup)
  logf("Backed up R startup file: %s -> %s", sQuote(file), sQuote(file_backup))
  stopifnot(file.exists(file_backup))
  file_backup
}
