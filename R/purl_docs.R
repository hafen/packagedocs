
#' Generate .R code files from docs
#'
#' @param docs_base base diretory where all .Rmd files are located to scrape code from
#' @param code_base base directory of where to put resulting .R files
#' @export
#' @importFrom knitr purl
purl_docs <- function(docs_base = "docs", code_base = "code") {

  ff <- list.files(docs_base, ".Rmd", full.names = TRUE)
  if (length(ff) > 0)
    ff <- ff[!grepl("^rd\\.Rmd$|^rd_skeleton\\.Rmd$", basename(ff))]

  if (length(ff) == 0)
    stop("There are no .Rmd files in ", docs_base)

  if (!file.exists(code_base)) {
    ans <- readline(paste("The path '", code_base, "' does not exist.  Should it be created? (y = yes) ", sep = ""))
    if (tolower(substr(ans, 1, 1)) == "y")
      dir.create(code_base)
  }

  ## generate the code/ files
  for (f in ff) {
    of <- file.path(code_base, gsub("Rmd$", "R", basename(f)))
    knitr::purl(f, of)
    # instead of documentation = 0 above, just tweak the comments a bit
    # this keeps spacing between sections without too the extra clutter
    tmp <- readLines(of)
    writeLines(gsub("## ----.*", "## ", tmp), of)
  }
}
