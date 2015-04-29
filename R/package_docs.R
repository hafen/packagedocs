#' Generate package docs
#'
#' @param toc should a table of contents be included?
#' @param toc_depth depth of the table of contents (max is 2 for this template)
#' @param \ldots parameters passed to \code{\link[rmarkdown]{html_document}}
#' @export
#' @import rmarkdown
#' @import htmltools
package_docs <- function(toc = TRUE, toc_depth = 2, extra_dependencies = NULL, ...) {

  template <-  system.file("html_assets/template.html", package = "packagedocs")
  # header <- system.file("assets/header.html", package = "packagedocs")

  if(toc_depth > 2)
    stop("toc_depth must be 2 or smaller", call. = FALSE)

  extra_dependencies <- c(list(rmarkdown:::html_dependency_jquery(),
    html_dependency_boot(), html_dependency_hglt(), html_dependency_fnta(),
    html_dependency_sticky_kit(), html_dependency_jquery_easing(), html_dependency_packagedocs_custom()), extra_dependencies)

  # call the base html_document function
  rmarkdown::html_document(toc = toc,
    toc_depth = toc_depth,
    fig_width = 6.5,
    fig_height = 4,
    mathjax = NULL,
    self_contained = FALSE,
    template = template,
    theme = NULL,
    highlight = NULL,
    extra_dependencies = extra_dependencies,
    pandoc_args = c("--variable", paste("current_year", format(Sys.time(), "%Y"), sep = "=")), ...)
    # includes = includes(before_body = header))
}

html_dependency_boot <- function() {
  htmltools::htmlDependency(name = "bootstrap",
    version = "3.3.2",
    src = system.file("html_assets/bootstrap", package = "packagedocs"),
    script = c("js/bootstrap.min.js",
     "shim/html5shiv.min.js",
     "shim/respond.min.js"),
    stylesheet = c("css/custom.css", "css/bootstrap.min.css"))
}

html_dependency_sticky_kit <- function() {
  htmltools::htmlDependency(name = "stickykit",
    version = "1.1.1",
    src = system.file("html_assets/sticky-kit", package = "packagedocs"),
    script = c("sticky-kit.min.js"))
}

html_dependency_jquery_easing <- function() {
  htmltools::htmlDependency(name = "jqueryeasing",
    version = "1.3",
    src = system.file("html_assets/jquery-easing", package = "packagedocs"),
    script = c("jquery.easing.min.js"))
}

html_dependency_packagedocs_custom <- function() {
  htmltools::htmlDependency(name = "packagedocscustom",
    version = "0.0.1",
    src = system.file("html_assets/packagedocs-custom", package = "packagedocs"),
    script = c("custom.js"))
}

html_dependency_hglt <- function() {
  htmltools::htmlDependency(name = "highlight",
    version = "8.4",
    src = system.file("html_assets/highlight", package = "packagedocs"),
    script = "highlight.pack.js",
    stylesheet = "tomorrow.css")
}

html_dependency_fnta <- function() {
  htmltools::htmlDependency(name = "fontawesome",
    version = "4.3.0",
    src = system.file("html_assets/fontawesome", package = "packagedocs"),
    stylesheet = "css/font-awesome.min.css")
}
