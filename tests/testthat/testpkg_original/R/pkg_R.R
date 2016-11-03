


#' Test file
#'
#' @param a test param number 1
#' @param b test param number 2
#' @rdname fn
#' @keywords programming
#' @examples
#' testpkg:::fn_a(4)
#' testpkg:::fn_b("world")
#' hist(rnorm(1000))
#' library(rbokeh)
fn_a <- function(a) {
  a
}

#' @rdname fn
fn_b <- function(b) {
  b
}

#' Test Keyword
#'
#' @param ... pass to print
#' @export
#' @keywords loess
#' @examples
#' runif(10)
keyword <- function(...) {
  print(...)
}

#' Test Internal
#'
#' @param ... pass to print
#' @export
#' @keywords internal
hidden <- function(...) {
  print(...)
}

#' Test Not Exported
#'
#' @param ... pass to print
#' @keywords debugging
#' @examples
#' hist(runif(100))
not_exported <- function(...) {
  print(...)
}
