


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

#' Test Xiaosu
#'
#' @param ... pass to print
#' @export
#' @keywords loess
test_xiaosu <- function(...) {
  print(...)
}


make_and_build <- function(code_path, pkg_name, view_output = FALSE) {
  docs_path <- file.path("_docs", pkg_name)
  packagedocs_init(code_path = code_path, docs_path = docs_path)
  render_docs(code_path = code_path, docs_path = docs_path,
    view_output = view_output, rd_toc_collapse = TRUE)
}

if (FALSE) {

  load_all(); document(); make_and_build("./", "packagedocs", TRUE) # nolint

  load_all(); make_and_build("~/_/git/R/ggobi_org/ggally/ggally", "GGally", TRUE) # nolint

  load_all(); make_and_build("~/_/git/gates/hbgd/hbgd", "hbgd", TRUE) # nolint

}
