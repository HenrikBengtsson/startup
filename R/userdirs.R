get_os <- function() {
  if (.Platform[["OS.type"]] == "windows") return("windows")
  if (Sys.info()["sysname"] == "Darwin") return("macos")
  if (.Platform[["OS.type"]] == "unix") return("unix")
  NA_character_
}


## REFERENCES:
## [1] https://docs.microsoft.com/en-us/windows/deployment/usmt/usmt-recognized-environment-variables
get_windows_local_appdata <- function() {
  ## Env var 'LOCALAPPDATA' should be defined on Windows Vista and later
  path <- Sys.getenv("LOCALAPPDATA", NA_character_)
  if (!is.na(path)) return(path)

  ## We might end up here because we're on Windows XP or for other reasons
  root <- Sys.getenv("USERPROFILE", NA_character_)
  if (is.na(root)) return(NA_character_)  ## Should not happen

  ## Is there an 'AppData/Local' folder?
  path <- file.path(root, "AppData" , "Local")
  if (!is.na(path)) return(path)

  ## Is there an 'Local Settings/Application Data' folder? (Windows XP)
  path <- file.path(root, "Local Settings", "Application Data")
  if (!is.na(path)) return(path)

  ## We shouldn't really end up here, but who knows ...
  NA_character_
}


find_cache_path <- function(dirs = c("R", utils::packageName())) {
  ## Per tools::R_user_dir(which = "cache") of R (>= 4.0.0)
  root <- Sys.getenv("R_USER_CACHE_DIR", NA_character_)
  if (is.na(root)) {
    root <- Sys.getenv("XDG_CACHE_HOME", NA_character_)
  }
  if (is.na(root)) {
    os <- get_os()
    root <- switch(os,
      windows = file.path(get_windows_local_appdata(), "R", "cache"),
      macos = file.path("~", "Library", "Caches", "org.R-project.R"),
      unix = file.path("~", ".cache"),
      NA_character_
    )
  }

  ## Failed to find a OS-specific cache folder?
  if (is.na(root)) {
    os <- get_os()
    stop("Failed to locate local cache folder on this operating system: ", os)
  }
  
  path <- c(root, dirs)
  path <- do.call(file.path, args = as.list(path))
  path <- normalizePath(path, mustWork = FALSE)

  path
}


find_config_path <- function(dirs = c("R", utils::packageName())) {
  ## Per tools::R_user_dir(which = "config") of R (>= 4.0.0)
  root <- Sys.getenv("R_USER_CONFIG_DIR", NA_character_)
  if (is.na(root)) {
    root <- Sys.getenv("XDG_CONFIG_HOME", NA_character_)
  }
  if (is.na(root)) {
    os <- get_os()
    root <- switch(os,
      windows = file.path(get_windows_local_appdata(), "R", "config"),
      macos = file.path("~", "Library", "Preferences", "org.R-project.R"),
      unix = file.path("~", ".config"),
      NA_character_
    )
  }

  ## Failed to find a OS-specific cache folder?
  if (is.na(root)) {
    os <- get_os()
    stop("Failed to locate local cache folder on this operating system: ", os)
  }
  
  path <- c(root, dirs)
  path <- do.call(file.path, args = as.list(path))
  path <- normalizePath(path, mustWork = FALSE)

  path
}

get_user_dir <- local({
  paths <- list()
  function(which = c("cache", "config"), create = TRUE) {
    which <- match.arg(which)
    path <- paths[[which]]
    if (is.null(path)) {
      path <- switch(which,
        cache = find_cache_path(),
        config = find_config_path()
      )
      paths[[which]] <<- path
    }

    if (create && !is_dir(path)) {
      dir.create(path, recursive = TRUE)
      stop_if_not(is_dir(path))
    }

    path
  }
})
