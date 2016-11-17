backup <- function(file) {
  stopifnot(file.exists(file))
  timestamp <- format(Sys.time(), "%Y%m%d-%H%M%S")
  fileB <- sprintf("%s.bak.%s", file, timestamp)
  file.copy(file, fileB)
  stopifnot(file.exists(fileB))
  fileB
}
