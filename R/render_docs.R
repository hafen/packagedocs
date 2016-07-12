#' Render packagedocs
#'
#' @param docs_path location of R Markdown docs directory
#' @param code_path location of R package source directory
#' @param main_toc_collapse use collapsing toc on main page
#' @param rd_toc_collapse use collapsing toc on rd page
#' @param lib_dir put assets in "assets" directory
#' @param render_main render main page
#' @param render_rd render rd page
#' @param view_output look at the output after render
#' @param rd_index optional path to rd layout yaml (if NULL, will search for "docs_path/rd_index.yaml" and use it if available)
#' @export
render_docs <- function(docs_path, code_path,
  main_toc_collapse = TRUE, rd_toc_collapse = FALSE,
  lib_dir = "assets", render_main = TRUE, render_rd = TRUE,
  view_output = TRUE, rd_index = NULL) {

  pdof1 <- package_docs(lib_dir = lib_dir, toc_collapse = main_toc_collapse)
  pdof2 <- package_docs(lib_dir = lib_dir, toc_collapse = rd_toc_collapse)

  wd <- getwd()

  if (! dir.exists(docs_path)) {
    stop(paste("docs_path:'", docs_path, "' does not exist", sep = "", collapse = ""))
  }
  setwd(docs_path)

  if (file.exists("assets")) {
    if (file.exists("assets_bak"))
      unlink("assets_bak", recursive = TRUE)
    file.rename("assets", "assets_bak")
  }

  on.exit({
    if (!file.exists("assets")) {
      file.rename("assets_bak", "assets")
    } else {
      unlink("assets_bak", recursive = TRUE)
    }
    setwd(wd)
  })

  # generate index.html
  if (render_main) {
    render("index.Rmd", output_format = pdof1)
    check_output("index.html")
    if (view_output)
      browseURL("index.html")
  }

  if (render_rd) {
    render_rd("rd_skeleton.Rmd", code_path, "./",
      rd_index = rd_index, output_format = pdof2)
    check_output("rd.html")
    if (view_output)
      browseURL("rd.html")
  }

}














render_docs2 <- function(docs_path, code_path,
  main_toc_collapse = TRUE, rd_toc_collapse = FALSE,
  lib_dir = "assets", render_main = TRUE, render_rd = TRUE,
  view_output = TRUE, rd_index = NULL) {

  render_main2(
    docs_path, code_path,
    toc_collapse = main_toc_collapse, lib_dir = lib_dir,
    render = render_main,
    view_output = view_output
  )
  render_rd2(
    docs_path, code_path,
    toc_collapse = rd_toc_collapse, lib_dir = lib_dir,
    render = render_rd,
    view_output = view_output,
    rd_index = rd_index
  )
}

lib_dir_pre <- function(lib_dir, lib_dir_bak) {
  if (file.exists(lib_dir)) {
    if (file.exists(lib_dir_bak))
      unlink(lib_dir_bak, recursive = TRUE)
    file.rename(lib_dir, lib_dir_bak)
  }
}

lib_dir_on_exit <- function(lib_dir, lib_dir_bak) {
  if (!file.exists(lib_dir)) {
    file.rename(lib_dir_bak, lib_dir)
  } else {
    unlink(lib_dir_bak, recursive = TRUE)
  }
}

render_main2 <- function(
  docs_path, code_path,
  toc_collapse = TRUE,
  lib_dir = "assets", lib_dir_bak = paste(lib_dir, "_main_bak", sep = ""),
  render = TRUE,
  view_output = TRUE
) {

  pdof1 <- package_docs(lib_dir = lib_dir, toc_collapse = toc_collapse)

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

  # generate index.html
  if (render) {
    render("index.Rmd", output_format = pdof1)
    check_output("index.html")
    if (view_output)
      browseURL("index.html")
  }

  file.path(docs_path, "index.html")
}





render_rd2 <- function(
  docs_path, code_path,
  toc_collapse = FALSE,
  lib_dir = "assets", lib_dir_bak = paste(lib_dir, "_rd_bak", sep = ""),
  render = TRUE,
  view_output = TRUE,
  rd_index = NULL
) {

  pdof2 <- package_docs(lib_dir = lib_dir, toc_collapse = toc_collapse)

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

  # generate rd.html
  if (render) {
    render_rd("rd_skeleton.Rmd", code_path, "./",
      rd_index = rd_index, output_format = pdof2)
    check_output("rd.html")
    if (view_output)
      browseURL("rd.html")
  }

  file.path(docs_path, "rd.html")
}
