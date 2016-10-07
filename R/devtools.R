
# direct copy of copy_vignettes from devtools
# added doc_dir as arg
# added extra_files to have dirs lib_dir, "docs_files", and "rd_files"
# added option to include or exclude sources
copy_vignettes_and_assets <- function (
  pkg,
  output_dir,
  extra_files = c(),
  extra_dirs = c(),
  include_vignette_source = TRUE
) {

  pkg <- devtools::as.package(pkg)
  doc_dir <- output_dir

  if (!file.exists(doc_dir)) {
    dir.create(doc_dir, recursive = TRUE, showWarnings = FALSE)
  }
  doc_dir_small <- gsub(pkg$path, "", doc_dir, fixed = TRUE)

  vigns <- tools::pkgVignettes(dir = pkg$path, output = TRUE, source = TRUE)
  if (length(vigns$docs) == 0) {
    return(invisible())
  }
  out_mv <- c(vigns$outputs, unlist(vigns$sources, use.names = FALSE))
  out_cp <- vigns$docs

  message("Moving ", paste(basename(out_mv), collapse = ", "), " to ", doc_dir)
  file.copy(out_mv, doc_dir, overwrite = TRUE)
  file.remove(out_mv)

  if (isTRUE(include_vignette_source)) {
    message("Copying ", paste(basename(out_cp), collapse = ", "), " to ", doc_dir)
    file.copy(out_cp, doc_dir, overwrite = TRUE)
  }

  find_vignette_extras <- getFromNamespace("find_vignette_extras", "devtools")
  extra_files <- append(extra_files, find_vignette_extras(pkg))
  for (dir_val in extra_dirs) {
    if (dir.exists(dir_val)) {
      extra_files <- append(extra_files, dir_val)
    }
  }
  extra_files <- unique(extra_files)
  if (length(extra_files) == 0) {
    return(invisible())
  }
  message(
    "Copying extra files ", paste(basename(extra_files), collapse = ", "),
    " to ", doc_dir_small
  )
  file.copy(extra_files, doc_dir, recursive = TRUE)

  invisible()
}


devtools_copy_vignettes <- getFromNamespace("copy_vignettes", "devtools")

#' Build CRAN and gh-pages vignettes
#'
#' Build CRAN html redirect vignettes that are placed in inst/doc/ that redirect to the gh-pages branch of the github url provided in the DESCRIPTION file.  This function is heavily inspired by \code{devtools::\link[devtools]{build_vignettes}()}.
#' @param pkg path to package. Provided directly to \code{devtools::\link[devtools]{as.package}()}
#' @param dependencies supplied directly to \code{devtools::\link[devtools]{install_deps}()}
#' @param output_dir directory where the fully contained vignette directory should be exported
#' @param extra_dirs list of directories that will be copied to the gh-pages that are not vignettes and should not be shipped with the package. Files that should be exist in both gh-pages and the package should be contained in the \code{vignettes/.install_extras} file.
#' @param delete_files list of files that should be deleted if they still exist when the function ends
#' @param devtools boolean to determine if the vignettes should be processed as self contained vignettes with devtools.  Runs \code{devtools::build_vignettes(pkg, dependencies)}
#' @param include_vignette_source boolean to determine if the vignettes should be copied to the destination directory.  Default behavior is to NOT copy the original vignettes
#' @export
build_vignettes <- function (
  pkg = ".",
  dependencies = "VignetteBuilder",
  output_dir = "_gh-pages",
  extra_dirs = file.path("vignettes", c(
    lazy_widgets_dir(),
    assets_dir(),
    docs_files_dir(),
    rd_files_dir()
  )),
  delete_files = file.path("vignettes", c(
    rd_temp_file_rmd(),
    ".build.timestamp",
    rd_file_html(),
    docs_file_html()
  )),
  devtools = FALSE,
  include_vignette_source = FALSE
) {

  on.exit({
    # make sure the defaults are set back to expected behavior
    is_self_contained_build(is_self_contained_build_default())
    is_cran_build(is_cran_build_default())

    # remove all temp directories if an error occurs
    for (fp in extra_dirs) {
      if (dir.exists(fp)) {
        unlink(fp, recursive = TRUE)
      }
    }

    # remove all extra files
    for (fp in delete_files) {
      if (file.exists(fp)) {
        unlink(fp)
      }
    }
  })

  if (identical(devtools, TRUE)) {
    return(devtools::build_vignettes(pkg = pkg, dependencies = dependencies))
  }

  pkg <- devtools::as.package(pkg)

  vigns <- tools::pkgVignettes(dir = pkg$path)
  if (is.null(vigns)) {
    message("Could not vignettes directory:\n",
      vigns$dir,
      "\nRun packagedocs::init_vignettes() to get started.")
  }

  if (length(vigns$docs) == 0) {
    message("Could not find docs files in vignettes directory:\n",
      vigns$dir,
      "\nPlease check your package's DESCRIPTION file to make sure there is an entry:",
      "\nVignetteBuilder: packagedocs")
    return()
  }

  if (pkg$package != "packagedocs") {
    message("Installing dependencies")
    devtools::install_deps(pkg, dependencies, upgrade = FALSE)
  }

  message("Building ", pkg$package, " vignettes")
  is_self_contained_build(FALSE)

  is_cran_build(TRUE)
  tools::buildVignettes(dir = pkg$path, tangle = TRUE, clean = TRUE)
  # devtools_copy_vignettes(pkg)
  copy_vignettes_and_assets(
    pkg,
    output_dir = file.path("inst", "doc"),
    extra_dirs = c(),
    extra_files = c(),
    include_vignette_source = include_vignette_source
  )

  rmd_files <- file.path("inst", "doc", c("docs.Rmd", "rd.Rmd"))
  rmds_exist <- file.exists(rmd_files)
  if (any(rmds_exist)) {
    if (rmds_exist[1]) {
      message("Removing copied docs.Rmd")
      unlink(rmd_files[1])
    }
    if (rmds_exist[2]) {
      message("Removing copied rd.Rmd")
      unlink(rmd_files[2])
    }
  }

  is_cran_build(FALSE)
  tools::buildVignettes(dir = pkg$path, tangle = TRUE, clean = FALSE)
  copy_vignettes_and_assets(
    pkg,
    output_dir = output_dir,
    extra_dirs = extra_dirs,
    extra_files = c(),
    include_vignette_source = include_vignette_source
  )

  invisible(TRUE)
}
