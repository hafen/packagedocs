


#' Test file
#'
#' @param a test param number 1
#' @param b test param number 2
#' @rdname test_fn
#' @keywords programming
#' @examples
#' packagedocs:::test_fn_a(4)
#' packagedocs:::test_fn_b("world")
#' hist(rnorm(1000))
test_fn_a <- function(a) {
  a
}

#' @rdname test_fn
test_fn_b <- function(b) {
  b
}

#' Test Keyword
#'
#' @param ... pass to print
#' @export
#' @keywords loess
test_keyword <- function(...) {
  print(...)
}

#' Test Internal
#'
#' @param ... pass to print
#' @export
#' @keywords internal
test_hidden <- function(...) {
  print(...)
}

#' Test Not Exported
#'
#' @param ... pass to print
#' @keywords debugging
test_not_exported <- function(...) {
  print(...)
}


make_and_build <- function(
  code_path, pkg_name, view_output = FALSE,
  docs_path = file.path("_docs", pkg_name)
) {

  packagedocs_init(code_path = code_path, docs_path = docs_path)
  render_docs(code_path = code_path, docs_path = docs_path,
    view_output = view_output, rd_toc_collapse = TRUE)
}

# make_and_build2 <- function(
#   code_path, pkg_name, view_output = FALSE,
#   docs_path = file.path("_docs", pkg_name)
# ) {
#
#   packagedocs_init(code_path = code_path, docs_path = docs_path)
#   render_docs2(code_path = code_path, docs_path = docs_path,
#     view_output = view_output, rd_toc_collapse = TRUE)
#   invisible()
# }

make_and_vig <- function(code_path = ".") {
  unlink(file.path(code_path, "vignettes"), recursive = TRUE)
  init_vignettes(code_path = code_path)
  devtools::build_vignettes()
  on.exit({
    devtools::load_all()
  })
}

if (FALSE) {

  load_all(); document(); make_and_build("./", "packagedocs", TRUE) # nolint

  load_all(); make_and_build("~/_/git/R/ggobi_org/ggally/ggally", "GGally", TRUE) # nolint

  load_all(); make_and_build("~/_/git/gates/hbgd/hbgd", "hbgd", TRUE) # nolint

  load_all(); make_and_build("./", "packagedocs", TRUE, "vignettes")
  load_all(); make_and_build2("./", "packagedocs", TRUE, "vignettes")

  load_all(); make_and_vig()

}
