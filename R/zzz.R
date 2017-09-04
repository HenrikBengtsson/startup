register_vignette_engine_during_build_only <- function(pkgname) {
  ## HACK: Only register vignette engine startup::selfonly during R CMD build
  if (Sys.getenv("R_CMD") == "") return()
#  pattern <- sprintf("(%s|buildVignettes)", pkgname)
#  if (!any(grepl(pattern, commandArgs()))) return()
 
  tools::vignetteEngine("selfonly", package = "startup", pattern = "[.]md$",
    weave = function(file, ...) {
      output <- sprintf("%s.html", tools::file_path_sans_ext(basename(file)))
      md <- readLines(file)
      md <- grep("%\\\\Vignette", md, invert = TRUE, value = TRUE)
      html <- commonmark::markdown_html(md, smart = FALSE, extensions = FALSE,
                                        normalize = FALSE)
      writeLines(html, con = output)
      output
    },

    tangle = function(file, ...) {
      ## As of R 3.3.2, vignette engines must produce tangled output, but as
      ## long as it contains all comments then 'R CMD build' will drop it.
      output <- sprintf("%s.R", tools::file_path_sans_ext(basename(file)))
      cat(sprintf("### This is an R script tangled from %s\n",
                  sQuote(basename(file))), file = output)
      output
    }
  )
}

.onLoad <- function(libname, pkgname) {
  register_vignette_engine_during_build_only(pkgname)
}
