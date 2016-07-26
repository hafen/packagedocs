# #' Render packagedocs
# #'
# #' @param docs_path location of R Markdown docs directory
# #' @param code_path location of R package source directory
# #' @param main_toc_collapse use collapsing toc on main page
# #' @param rd_toc_collapse use collapsing toc on rd page
# #' @param lib_dir put assets in "assets" directory
# #' @param lib_dir_bak backup assets directory
# #' @param render_main render main page
# #' @param render_rd render rd page
# #' @param view_output look at the output after render
# #' @param rd_index optional path to rd layout yaml (if NULL, will search for "docs_path/rd_index.yaml" and use it if available)
# #' @export
# render_docs <- function(docs_path, code_path,
#   main_toc_collapse = TRUE, rd_toc_collapse = FALSE,
#   render_main = TRUE, render_rd = TRUE,
#   lib_dir = assets_dir(), lib_dir_bak = paste0(lib_dir, "_bak"),
#   view_output = TRUE, rd_index = NULL) {
#
#   pdof1 <- package_docs(lib_dir = lib_dir, toc_collapse = main_toc_collapse)
#   pdof2 <- package_docs(lib_dir = lib_dir, toc_collapse = rd_toc_collapse)
#
#   wd <- getwd()
#
#   if (! dir.exists(docs_path)) {
#     stop(paste("docs_path:'", docs_path, "' does not exist", sep = "", collapse = ""))
#   }
#   setwd(docs_path)
#
#
#   lib_dir_pre(lib_dir, lib_dir_bak)
#   on.exit({
#     lib_dir_on_exit(lib_dir, lib_dir_bak)
#     setwd(wd)
#   })
#
#   # generate index.html
#   if (render_main) {
#     render("index.Rmd", output_format = pdof1)
#     check_output("index.html")
#     if (view_output)
#       browseURL("index.html")
#   }
#
#   if (render_rd) {
#     render_rd("rd_skeleton.Rmd", code_path, "./",
#       rd_index = rd_index, output_format = pdof2)
#     check_output("rd.html")
#     if (view_output)
#       browseURL("rd.html")
#   }
#
# }














# render_docs2 <- function(docs_path, code_path,
#   main_toc_collapse = TRUE, rd_toc_collapse = FALSE,
#   lib_dir = "assets", render_main = TRUE, render_rd = TRUE,
#   view_output = TRUE, rd_index = NULL) {
#
#   render_main2(
#     docs_path, code_path,
#     toc_collapse = main_toc_collapse, lib_dir = lib_dir,
#     render = render_main,
#     view_output = view_output
#   )
#   render_rd2(
#     docs_path, code_path,
#     toc_collapse = rd_toc_collapse, lib_dir = lib_dir,
#     render = render_rd,
#     view_output = view_output,
#     rd_index = rd_index
#   )
# }

lib_dir_pre <- function(lib_dir, lib_dir_bak) {
  if (file.exists(lib_dir)) {
    if (file.exists(lib_dir_bak))
      unlink(lib_dir_bak, recursive = TRUE)
    file.rename(lib_dir, lib_dir_bak)
  }
}

lib_dir_on_exit <- function(lib_dir, lib_dir_bak) {
  if (!file.exists(lib_dir)) {
    if (file.exists(lib_dir_bak)) {
      file.rename(lib_dir_bak, lib_dir)
    }
  } else {
    unlink(lib_dir_bak, recursive = TRUE)
  }
}


#' Render vignette files
#'
#' @param docs_path location of index file
#' @param code_path location of library
#' @param toc_collapse boolean to determine if the table of contents should be collapsed
#' @param lib_dir directory where all assets are kept
#' @param lib_dir_bak backup directory where all assets are kept
#' @param render boolean to determine if the files should be rendered
#' @param view_output boolean to determine if a browser should be opened to the files
#' @param input_file_rmd rmd file input
#' @param output_file_html html file where the output is placed
#' @param self_contained boolean to determine if the html should be fully self contained
#' @param shell_build boolean to determine if the html should redirect to the github location of the package
#' @param verbose boolean to determine if ouput should be displayed
#' @rdname vignette_render
#' @export
vig_render_index <- function(
  docs_path, code_path,
  toc_collapse = TRUE,
  lib_dir = assets_dir(), lib_dir_bak = paste(lib_dir, "_main_bak", sep = ""),
  render = TRUE,
  view_output = TRUE,
  input_file_rmd = index_file_rmd(),
  output_file_html = index_file_html(),
  self_contained = is_self_contained_build(),
  shell_build = is_shell_build(),
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

  lib_dir_pre(lib_dir, lib_dir_bak)
  on.exit({
    lib_dir_on_exit(lib_dir, lib_dir_bak)
    setwd(wd)
  })

  verbose <- identical(verbose, TRUE)
  wrapper_fn <- if (verbose) identity else suppressMessages

  # generate index.html
  if (render) {
    if (shell_build) {
      wrapper_fn(render_shell(
        code_path = code_path,
        output_file_html = output_file_html,
        is_rd_shell = FALSE
      ))
    } else {
      wrapper_fn(render(input_file_rmd, output_format = pdof1, quiet = !verbose))
      wrapper_fn(check_output(output_file_html))
    }
    if (view_output)
      browseURL(output_file_html)
  }

  file.path(docs_path, output_file_html)
}



#' @param run_examples boolean to determine if the examples should be executed
#' @param rd_index location of yaml file that describes the function references of the package.  Defaults to "rd_index.yaml"
#' @param temp_file_rmd temp rmd file that is a concatination of the input_file_rmd and the compiled rd_index.yaml file
#' @rdname vignette_render
#' @export
vig_render_rd <- function(
  docs_path, code_path,
  toc_collapse = FALSE,
  lib_dir = assets_dir(), lib_dir_bak = paste(lib_dir, "_rd_bak", sep = ""),
  run_examples = FALSE,
  render = TRUE,
  view_output = TRUE,
  rd_index = NULL,
  input_file_rmd = rd_temp_file_rmd(),
  temp_file_rmd = rd_file_rmd(),
  output_file_html = rd_file_html(),
  self_contained = is_self_contained_build(),
  shell_build = is_shell_build(),
  verbose = TRUE
) {

  delete_temp_rmd <- TRUE

  wd <- getwd()

  if (! dir.exists(docs_path)) {
    stop(paste("docs_path:'", docs_path, "' does not exist", sep = "", collapse = ""))
  }
  setwd(docs_path)

  lib_dir_pre(lib_dir, lib_dir_bak)
  on.exit({
    lib_dir_on_exit(lib_dir, lib_dir_bak)
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

    if (shell_build) {
      render_shell(
        code_path = code_path,
        output_file_html = output_file_html,
        is_rd_shell = TRUE
      )
    } else {
      wrapper_fn(render_rd(
        input_file_rmd,
        code_path = code_path,
        # docs_path = "./",
        rd_index = rd_index, output_format = pdof2,
        output_file_rmd = temp_file_rmd,
        output_file_html = output_file_html,
        verbose = verbose,
        run_examples = run_examples
      ))
      wrapper_fn(check_output(output_file_html))
      if (delete_temp_rmd) {
        unlink(temp_file_rmd)
      }
    }
    if (view_output)
      browseURL(output_file_html)
  }

  file.path(docs_path, output_file_html)
}
