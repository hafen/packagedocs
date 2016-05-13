#' Render packagedocs
#'
#' @param docs_path location of R Markdown docs directory
#' @param code_path location of R package source directory
#' @param package_name the name of the package, e.g. "packagedocs"
#' @param main_toc_collapse use collapsing toc on main page
#' @param rd_toc_collapse use collapsing toc on rd page
#' @param lib_dir put assets in "assets" directory
#' @param render_main render main page
#' @param render_rd render rd page
#' @param view_output look at the output after render
#' @param rd_index optional path to rd layout yaml (if NULL, will search for "docs_path/rd_index.yaml" and use it if available)
#' @export
render_docs <- function(docs_path, code_path, package_name,
  main_toc_collapse = TRUE, rd_toc_collapse = TRUE,
  lib_dir = "assets", render_main = TRUE, render_rd = TRUE,
  view_output = TRUE, rd_index = NULL) {

  pdof1 <- package_docs(lib_dir = lib_dir, toc_collapse = main_toc_collapse)
  pdof2 <- package_docs(lib_dir = lib_dir, toc_collapse = rd_toc_collapse)

  wd <- getwd()

  # if inst is not in package repo, create it
  if(!file.exists(inst_path <- file.path(code_path, "inst"))) {
    dir.create(inst_path)
    existed_inst_path <- FALSE
  } else {
    existed_inst_path <- TRUE
  }

  # if inst/staticdocs is not there, create it
  if(!file.exists(staticdoc_path <- file.path(inst_path, "staticdocs"))) {
    dir.create(staticdoc_path)
    existed_staticdoc_path <- FALSE
  } else {
    existed_staticdoc_path <- TRUE
  }

  setwd(docs_path)

  if(file.exists("assets")) {
    if(file.exists("assets_bak"))
      unlink("assets_bak", recursive = TRUE)
    file.rename("assets", "assets_bak")
  }

  on.exit({
    # remove the staticdocs directory if it didn't previously exist
    if(!existed_staticdoc_path)
      unlink(staticdoc_path, recursive = TRUE)
    # remove the inst directory if it didn't previously exist
    if(!existed_inst_path)
      unlink(inst_path, recursive = TRUE)

    if(!file.exists("assets")) {
      file.rename("assets_bak", "assets")
    } else {
      unlink("assets_bak", recursive = TRUE)
    }
    setwd(wd)
  })

  # generate index.html
  if(render_main) {
    render("index.Rmd", output_format = pdof1)
    check_output("index.html")
    if(view_output)
      browseURL("index.html")
  }

  if(render_rd) {
    if(!file.exists(file.path(code_path, "inst/staticdocs")))
      dir.create(file.path(code_path, "inst/staticdocs"), recursive = TRUE)
    render_rd("rd_skeleton.Rmd", package_name, code_path,
      rd_index = rd_index, output_format = pdof2)
    check_output("rd.html")
    if(view_output)
      browseURL("rd.html")
  }

}
