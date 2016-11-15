# Save command-line history upon exit
.Last <- function() {
  if (base::interactive()) try(utils::savehistory(), silent = TRUE)
}

# TAB-completions
utils::rc.settings(ipck = TRUE)
