make_alias_id <- function(alias_file_name) {
  rd_file <- gsub("\\.Rd", "", alias_file_name)
  alias_id <- paste(rd_file, "_alias", sep = "")
  alias_id
}

#' Translate a reference to a package function into a link to that function's documentation in rd.html
#'
#' This is meant to be used inside your packagedocs vignette docs.Rmd and rd.Rmd files
#'
#' @param txt a string or expression referencing a function or other Rd object
#' @param rd_html the string to be used in the href string pointing to the page where Rd documentation is provided
#' @param pkg path to package being documented. Works when within sub-package directories
#'
#' @details Instead of using \code{&#96;myfunction()&#96;} when talking about a package function \code{myfunction} inside your .Rmd file, you can use \code{&#96;r rd_link(myfunction())&#96;} or even things like \code{&#96;r rd_link(myfunction(arg1 = 1, ...))&#96;} and it will turn it into an href pointing to the online documentation of your package function \code{myfunction} in the page rendered by packagedocs.
#' @export
rd_link <- function(txt, rd_html = rd_file_html(), pkg = ".") {
  res <- try(txt, silent = TRUE)

  if (inherits(res, "try-error")) {
    txt <- deparse(substitute(txt))
  }

  # get rid of quotes if it is quoted
  txt <- gsub("^\"|\"$", "", txt)
  fn_paren <- NULL
  if (grepl("\\(", txt)) {
    fn_paren <- gsub("^[^\\(]+(\\(.*\\))$", "\\1", txt)
  }


  # remove everything but function name
  fn_code <- gsub("^([^\\(]+)\\(.*", "\\1", txt)[1]

  # get the package name if provided
  t_package <- NULL
  if (grepl("^[^:]+::", fn_code)) {
    t_package <- gsub("^([^:]+)::.*", "\\1", fn_code)
    if (nchar(t_package) == 0) {
      t_package <- NULL
    }
    fn_code <- gsub("^[^:\\(]+::(.*)", "\\1", fn_code)
  }

  # print(txt)
  # print(list(t_package, fn_code, fn_paren))
  # browser()

  # get the package info
  pkg_info <- as_sd_package(pkg)
  find_topic_package <- t_package
  if (!is.null(find_topic_package)) {
    if (find_topic_package == pkg_info$package) {
      find_topic_package <- NULL
    }
  }

  # get the help location info
  loc <- find_topic(fn_code, find_topic_package, pkg_info$rd_index)

  if (is.null(loc)) {
    message("Can't find help topic '", fn_code, "'")
    return(paste0("<code>", txt, "</code>"))
  }
  if (is.null(loc$package)) {
    anchor <- make_alias_id(gsub(".html$", "", loc$file))
    loc$file <- paste0("rd.html#", anchor)
  }

  link <- make_link(loc, fn_code, pkg_info)

  if (!is.null(t_package)) {
    t_package <- paste0(t_package, "::")
  }
  ret <- paste0("<code>", t_package, link, fn_paren, "</code>")

  return(ret)
}
