
#' Generate rd.html file
#'
#' @param rd_skeleton path to a .Rmd file that contains the header to use for the rd.Rmd
#' @param package_name the name of the package, e.g. "packagedocs"
#' @param code_path path to the source code directory of the package
#' @param rd_index path to yaml file with index layout information
#' @param exclude vector of Rd entry names to exclude from the resulting document
#' @param output_format passed to \code{\link[rmarkdown]{render}} - \code{\link{package_docs}} is used by default
#' @param output directory to put the output rd.Rmd and rd.html file
#' @export
render_rd <- function(rd_skeleton, package_name, code_path, rd_index = NULL, exclude = NULL, output_format = NULL, output = ".") {
  a <- rd_template(package_name, code_path, rd_index, exclude)

  if (!file.exists(rd_skeleton))
    stop("'rd_skeleton' file ", rd_skeleton, " doesn't exist.", call. = FALSE)

  if (!file.exists(output))
    stop("'output' directory ", output, " doesn't exist.", call. = FALSE)

  sk <- readLines(rd_skeleton)

  out_path <- normalizePath(output)
  rd_file <- file.path(out_path, "rd.Rmd")
  lib_dir <- file.path(out_path, "assets")

  if (is.null(output_format))
    output_format <- package_docs(lib_dir = lib_dir)
  cat(paste(paste(sk, collapse = "\n"), a, sep = "\n"), file = rd_file)
  render(rd_file, output_format = output_format)
}
