


#' Test file
#'
#' @param a test param number 1
#' @param b test param number 2
#' @rdname test_fn
#' @examples
#' test_fn_a(4)
#' test_fn_b("world")
#' hist(rnorm(1000))
test_fn_a <- function(a) {
  a
}

#' @rdname test_fn
test_fn_b <- function(b) {
  b
}


if (FALSE) {

  bcode_path <- "./"
  bdocs_path <- "_docs"
  bpackage_name <- NULL
  load_all(); document(); packagedocs::packagedocs_init(code_path = bcode_path, docs_path = bdocs_path)
  load_all(); document(); render_docs(docs_path = bdocs_path, code_path = bcode_path, package_name = "packagedocs", view_output = FALSE)
}
