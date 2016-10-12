#' Render vignette files
#'
#' @param docs_path location of docs file
#' @param code_path location of library
#' @param toc_collapse boolean to determine if the table of contents should be collapsed
#' @param lib_dir directory where all assets are kept
#' @param render boolean to determine if the files should be rendered
#' @param view_output boolean to determine if a browser should be opened to the files
#' @param input_file_rmd rmd file input
#' @param output_file_html html file where the output is placed
#' @param self_contained boolean to determine if the html should be fully self contained
#' @param verbose boolean to determine if ouput should be displayed
#' @rdname vignette_render
#' @export
vig_render_docs <- function(
  docs_path = "vignettes", code_path = ".",
  toc_collapse = TRUE,
  lib_dir = assets_dir(),
  render = TRUE,
  view_output = TRUE,
  input_file_rmd = docs_file_rmd(),
  output_file_html = docs_file_html(),
  self_contained = FALSE,
  verbose = TRUE
) {

  pdof1 <- package_docs(
    lib_dir = lib_dir,
    toc_collapse = toc_collapse,
    self_contained = self_contained
  )

  wd <- getwd()

  if (! dir.exists(docs_path)) {
    stop(paste("docs_path:'", docs_path, "' does not exist", sep = "", collapse = ""))
  }

  setwd(docs_path)
  on.exit({
    setwd(wd)
  })

  verbose <- identical(verbose, TRUE)
  wrapper_fn <- if (verbose) identity else suppressMessages

  # generate docs.html
  if (render) {
    wrapper_fn(render(input_file_rmd, output_format = pdof1, quiet = !verbose))
    wrapper_fn(check_output(output_file_html))

    if (view_output) {
      browseURL(output_file_html)
    }
  }

  file.path(docs_path, output_file_html)
}


#' @param rd_index location of yaml file that describes the function references of the package.  Defaults to "rd_index.yaml"
#' @param temp_file_rmd temp rmd file that is a concatination of the input_file_rmd and the compiled rd_index.yaml file
#' @rdname vignette_render
#' @export
vig_render_rd <- function(
  docs_path = "vignettes", code_path = ".",
  toc_collapse = FALSE,
  lib_dir = assets_dir(),
  render = TRUE,
  view_output = TRUE,
  rd_index = NULL,
  input_file_rmd = rd_file_rmd(),
  temp_file_rmd = rd_temp_file_rmd(),
  output_file_html = rd_file_html(),
  self_contained = FALSE,
  verbose = TRUE
) {

  delete_temp_rmd <- TRUE

  wd <- getwd()

  if (! dir.exists(docs_path)) {
    stop(paste("docs_path:'", docs_path, "' does not exist", sep = "", collapse = ""))
  }
  setwd(docs_path)

  on.exit({
    setwd(wd)
  })

  verbose <- identical(verbose, TRUE)
  wrapper_fn <- if (verbose) identity else suppressMessages

  # generate rd.html
  if (render) {

    pdof2 <- package_docs(
      lib_dir = lib_dir,
      toc_collapse = toc_collapse,
      self_contained = self_contained
    )

    wrapper_fn(render_rd(
      input_file_rmd,
      code_path = code_path,
      # docs_path = "./",
      rd_index = rd_index, output_format = pdof2,
      output_file_rmd = temp_file_rmd,
      output_file_html = output_file_html,
      verbose = verbose
    ))
    wrapper_fn(check_output(output_file_html))
    if (delete_temp_rmd) {
      unlink(temp_file_rmd)
    }

    if (view_output) {
      browseURL(output_file_html)
    }
  }

  file.path(docs_path, output_file_html)
}



#' @export
#' @rdname vignette_render
#' @param ... parameters passed directly to \code{vig_render_rd} or \code{vig_render_docs}
rd_render <- function(...) {
  vig_render_rd(...)
}


#' @export
#' @rdname vignette_render
docs_render <- function(...) {
  vig_render_docs(...)
}
