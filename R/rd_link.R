#' Translate a reference to a package function into a link to that function's documentation in rd.html
#'
#' This is meant to be used inside your packagedocs .Rmd files
#'
#' @param txt a string or expression referencing a function or other Rd object
#' @param rd_page the string to be used in the href string pointing to the page where Rd documentation is provided
#'
#' @details Instead of using \code{`myfunction()`} when talking about a package function \code{myfunction} inside your .Rmd file, you can use \code{`rd_link(myfunction())`} or even things like \code{`rd_link(myfunction(arg1 = 1, ...))`} and it will turn it into an href pointing to the online documentation of your package function \code{myfunction} in the page rendered by \code{\link{render_docs}}.
#' @export
rd_link <- function(txt, rd_page = "rd.html") {
  res <- try(txt, silent = TRUE)

  if(inherits(res, "try-error"))
    txt <- deparse(substitute(txt))

  # get rid of quotes if it is quoted
  txt <- gsub("^\"|\"$", "", txt)

  # remove everything but function name
  txt2 <- gsub("(.*)\\(.*", "\\1", txt)
  txt2 <- gsub("\\.", "_", tolower(gsub("\\(\\)", "", txt2)))

  paste0("<code><a target='_blank' href='", rd_page, "#", txt2, "'>", txt, "</a></code>")
}
