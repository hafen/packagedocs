#' Generate package docs
#'
#' @param toc should a table of contents be included?
#' @param toc_depth depth of the table of contents (max is 2 for this template)
#' @param toc_collapse should the table of contents have collapsible subsections?
#' @param extra_dependencies passed to the rmarkdown rendering function
#' @param self_contained passed to the rmarkdown rendering function
#' @param \ldots parameters passed to the rmarkdown rendering function
#' @param lazyrmd_render_fn,lazyrmd_render_package arguments of \code{lazyrmd::\link[lazyrmd]{lazy_render}}.  Defaults to render with \code{rmarkdown::html_document}
#' @export
#' @import rmarkdown
#' @import htmltools
package_docs <- function(
  toc = TRUE,
  toc_depth = 2,
  toc_collapse = FALSE,
  extra_dependencies = NULL,
  self_contained = FALSE,
  ...,
  lazyrmd_render_fn = "html_document",
  lazyrmd_render_package = "rmarkdown"
) {

  template <-  system.file("html_assets/template.html", package = "packagedocs")
  # header <- system.file("assets/header.html", package = "packagedocs")

  if (toc_depth > 2)
    stop("toc_depth must be 2 or smaller", call. = FALSE)

  pddep <- html_dependency_packagedocs()
  if (toc_collapse) {
    pddep$script <- setdiff(pddep$script, "pd-sticky-toc.js")
  } else {
    pddep$script <- setdiff(pddep$script, "pd-collapse-toc.js")
  }

  extra_dependencies <- c(
    list(
      html_dependency_jquery(),
      html_dependency_boot(),
      html_dependency_hglt(),
      html_dependency_fnta(),
      html_dependency_sticky_kit(),
      html_dependency_jquery_easing(),
      lazyrmd::html_dependency_recliner(),
      pddep
    ),
    extra_dependencies
  )

  # call the lazy render function that wraps rmarkdown::html_document
  lazyrmd::lazy_render(
    lazyrmd_render_fn = lazyrmd_render_fn,
    lazyrmd_render_package = lazyrmd_render_package,
    toc = toc,
    toc_depth = toc_depth,
    fig_width = 6.5,
    fig_height = 4,
    mathjax = NULL,
    self_contained = self_contained,
    template = template,
    theme = NULL,
    highlight = NULL,
    extra_dependencies = extra_dependencies,
    pandoc_args = c("--variable", paste("current_year", format(Sys.time(), "%Y"), sep = "=")),
    ...
  )
  # includes = includes(before_body = header))
}

html_dependency_jquery <- getFromNamespace("html_dependency_jquery", "rmarkdown")

html_dependency_boot <- function() {
  htmltools::htmlDependency(name = "bootstrap",
    version = "3.3.2",
    src = system.file("html_assets/bootstrap", package = "packagedocs"),
    script = c("js/bootstrap.min.js", "shim/html5shiv.min.js", "shim/respond.min.js"),
    stylesheet = c("css/bootstrap.min.css"))
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

html_dependency_packagedocs <- function() {
  htmltools::htmlDependency(name = "packagedocs",
    version = "0.0.1",
    src = system.file("html_assets/packagedocs", package = "packagedocs"),
    script = c("pd.js", "pd-sticky-toc.js", "pd-collapse-toc.js"),
    stylesheet = "pd.css")
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
