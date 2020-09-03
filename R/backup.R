backup <- function(file, quiet = FALSE) {
  if (quiet) notef <- function(...) NULL

  stop_if_not(file.exists(file))
  size <- file_size(file)
  
  timestamp <- format(Sys.time(), "%Y%m%d-%H%M%S")
  backup_file <- sprintf("%s.bak.%s", file, timestamp)
  ## Was another backup file created just before during the same second?
  if (file.exists(backup_file)) {
    timestamp <- format(Sys.time(), "%Y%m%d-%H%M%OS3")
    backup_file <- sprintf("%s.bak.%s", file, timestamp)
  }
  stop_if_not(!file.exists(backup_file))
  res <- file.copy(file, backup_file, overwrite = FALSE)

  backup_size <- file_size(backup_file)
  notef("Backed up R startup file: %s (%d bytes) -> %s (%d bytes)",
        squote(file), size, squote(backup_file), backup_size)
  stop_if_not(file.exists(backup_file), identical(backup_size, size), res)
  
  backup_file
}
