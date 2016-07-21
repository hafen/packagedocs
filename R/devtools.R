

# direct copy of copy_vignettes from devtools
# added doc_dir as arg
# added extra_files to have dirs lib_dir, "index_files", and "rd_files"
copy_vignettes_and_assets <- function (
  pkg,
  output_dir = "_gh-pages",
  lib_dir = "assets"
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
  message("Moving ", paste(basename(out_mv), collapse = ", "), " to ", doc_dir_small)
  file.copy(out_mv, doc_dir, overwrite = TRUE)
  file.remove(out_mv)
  message("Copying ", paste(basename(out_cp), collapse = ", "), " to ", doc_dir_small)
  file.copy(out_cp, doc_dir, overwrite = TRUE)

  vig_lib_dir <- file.path(pkg$path, "vignettes", lib_dir)
  vig_index_dir <- file.path(pkg$path, "vignettes", "index_files")
  vig_rd_dir <- file.path(pkg$path, "vignettes", "rd_files")

  find_vignette_extras <- getFromNamespace("find_vignette_extras", "devtools")
  extra_files <- find_vignette_extras(pkg)
  for (dir_val in c(vig_lib_dir, vig_index_dir, vig_rd_dir)) {
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

  remove_dir <- function(d) {
    if (dir.exists(d)) {
      unlink(d, recursive = TRUE)
    }
  }
  remove_dir(file.path(pkg$path, "vignettes", lib_dir))
  remove_dir(file.path(pkg$path, "vignettes", "index_files"))
  remove_dir(file.path(pkg$path, "vignettes", "rd_files"))
  invisible()
}


devtools_copy_vignettes <- getFromNamespace("copy_vignettes", "devtools")

#' Build shell and gh-pages vignettes
#'
#' Build shell html vignettes that are placed in inst/doc/ that redirect to the gh-pages branch of the github url provided in the DESCRIPTION file.  This function is heavily inspired by \code{devtools::\link[devtools]{build_vignettes}()}.
#' @param pkg path to package. Provided directly to \code{devtools::\link[devtools]{as.package}()}
#' @param dependencies supplied directly to \code{devtools::\link[devtools]{install_deps}()}
#' @param output_dir directory where the fully contained vignette directory should be exported
#' @param devtools boolean to determine if the vignettes should be processed as self contained vignettes with devtools.  Runs \code{devtools::build_vignettes(pkg, dependencies)}
#' @export
build_vignettes <- function (
  pkg = ".",
  dependencies = "VignetteBuilder",
  output_dir = "_gh-pages",
  devtools = FALSE
) {

  on.exit({
    # make sure the defaults are set back to expected behavior
    is_self_contained_build(is_self_contained_build_default())
    is_shell_build(is_shell_build_default())

    # remove all temp directories if an error occurs
    fp_as <- file.path("vignettes", "assets")
    fp_index <- file.path("vignettes", "index_files")
    fp_rd <- file.path("vignettes", "rd_files")
    for (fp in c(fp_as, fp_index, fp_rd)) {
      if (dir.exists(fp)) {
        unlink(fp, recursive = TRUE)
      }
    }

    fp_com <- file.path("vignettes", "rd_combined.Rmd")
    fp_time <- file.path("vignettes", ".build.timestamp")
    for (fp in c(fp_com, fp_time)) {
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
  if (length(vigns$docs) == 0) {
    return()
  }
  devtools::install_deps(pkg, dependencies, upgrade = FALSE)
  message("Building ", pkg$package, " vignettes")


  is_self_contained_build(FALSE)

  is_shell_build(TRUE)
  tools::buildVignettes(dir = pkg$path, tangle = TRUE, clean = TRUE)
  devtools_copy_vignettes(pkg)

  is_shell_build(FALSE)
  tools::buildVignettes(dir = pkg$path, tangle = TRUE, clean = FALSE)
  copy_vignettes_and_assets(pkg, output_dir = output_dir)

  invisible(TRUE)
}
