
all_pkgdocs_engines <- function() {
  # c("packagedocs::redirect", "packagedocs::redirect_index")
  c("packagedocs::redirect")
}


devtools_copy_vignettes_two <- function (
  pkg,
  to_dir = file.path(pkg$path, "inst", "doc")
) {
    pkg <- as.package(pkg)

    lapply(to_dir, function(to_dir_) {
      if (!file.exists(to_dir_)) {
        dir.create(to_dir_, recursive = TRUE, showWarnings = FALSE)
      }
    })
    vigns <- tools::pkgVignettes(dir = pkg$path, output = TRUE,
        source = TRUE)
    if (length(vigns$docs) == 0) {
      return(invisible())
    }
    out_mv <- c(vigns$outputs, unlist(vigns$sources, use.names = FALSE))
    out_cp <- vigns$docs
    lapply(to_dir, function(to_dir_) {
      message("Moving ", paste(basename(out_mv), collapse = ", "),
          " to ", to_dir_)
      file.copy(out_mv, to_dir_, overwrite = TRUE)
    })
    file.remove(out_mv)

    out_cp <- out_cp[!(vigns$engines %in% all_pkgdocs_engines())]
    if (length(out_cp) > 0) {
      lapply(to_dir, function(to_dir_) {
        message("Copying ", paste(basename(out_cp), collapse = ", "),
            " to ", to_dir_)
        file.copy(out_cp, to_dir_, overwrite = TRUE)
      })
    }

    find_vignette_extras <- getFromNamespace("find_vignette_extras", "devtools")
    extra_files <- find_vignette_extras(pkg)
    if (length(extra_files) == 0) {
      return(invisible())
    }
    lapply(to_dir, function(to_dir_) {
      message("Copying extra files ", paste(basename(extra_files),
          collapse = ", "), " to ", to_dir_)
      file.copy(extra_files, to_dir_, recursive = TRUE)
    })
    invisible()
}


#
# # direct copy of copy_vignettes from devtools
# # added doc_dir as arg
# # added extra_files to have dirs lib_dir, "docs_files", and "rd_files"
# # added option to include or exclude sources
# copy_vignettes_and_assets <- function (
#   pkg,
#   output_dir,
#   extra_files = c(),
#   extra_dirs = c(),
#   include_vignette_source = TRUE
# ) {
#
#   pkg <- devtools::as.package(pkg)
#   doc_dir <- output_dir
#
#   if (!file.exists(doc_dir)) {
#     dir.create(doc_dir, recursive = TRUE, showWarnings = FALSE)
#   }
#   doc_dir_small <- gsub(pkg$path, "", doc_dir, fixed = TRUE)
#
#   vigns <- tools::pkgVignettes(dir = pkg$path, output = TRUE, source = TRUE)
#   if (length(vigns$docs) == 0) {
#     return(invisible())
#   }
#   out_mv <- c(vigns$outputs, unlist(vigns$sources, use.names = FALSE))
#   out_cp <- vigns$docs
#
#   message("Moving ", paste(basename(out_mv), collapse = ", "), " to ", doc_dir)
#   file.copy(out_mv, doc_dir, overwrite = TRUE)
#   file.remove(out_mv)
#
#   if (isTRUE(include_vignette_source)) {
#     message("Copying ", paste(basename(out_cp), collapse = ", "), " to ", doc_dir)
#     file.copy(out_cp, doc_dir, overwrite = TRUE)
#   }
#
#   find_vignette_extras <- getFromNamespace("find_vignette_extras", "devtools")
#   extra_files <- append(extra_files, find_vignette_extras(pkg))
#   for (dir_val in extra_dirs) {
#     if (dir.exists(dir_val)) {
#       extra_files <- append(extra_files, dir_val)
#     }
#   }
#   extra_files <- unique(extra_files)
#   if (length(extra_files) == 0) {
#     return(invisible())
#   }
#   message(
#     "Copying extra files ", paste(basename(extra_files), collapse = ", "),
#     " to ", doc_dir_small
#   )
#   file.copy(extra_files, doc_dir, recursive = TRUE)
#
#   invisible()
# }


# devtools_copy_vignettes <- getFromNamespace("copy_vignettes", "devtools")

#' Build CRAN and gh-pages vignettes
#'
#' Build CRAN html redirect vignettes that are placed in inst/doc/ that redirect to the gh-pages branch of the github url provided in the DESCRIPTION file.  This function is heavily inspired by \code{devtools::\link[devtools]{build_vignettes}()}.
#' @param pkg path to package. Provided directly to \code{devtools::\link[devtools]{as.package}()}
#' @param dependencies supplied directly to \code{devtools::\link[devtools]{install_deps}()}
#' @param output_dir directory where the fully contained vignette directory should be exported
#' @param extra_dirs list of directories that will be copied to the gh-pages that are not vignettes and should not be shipped with the package. Files that should be exist in both gh-pages and the package should be contained in the \code{vignettes/.install_extras} file.
#' @param delete_files list of files that should be deleted if they still exist when the function ends
#' @param include_vignette_source boolean to determine if the vignettes should be copied to the destination directory.  Default behavior is to NOT copy the original vignettes
#' @export
build_vignettes <- function (
  pkg = ".",
  dependencies = "VignetteBuilder",
  output_dir = "_gh-pages",
  extra_dirs = file.path("vignettes", c(
    lazy_widgets_dir(),
    assets_dir()
  )),
  delete_files = file.path("vignettes", c(
    ".build.timestamp"
  )),
  include_vignette_source = FALSE
) {

  on.exit({
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

  # build regular vigs into inst/doc
  tools::buildVignettes(dir = pkg$path, tangle = TRUE, clean = TRUE)
  devtools_copy_vignettes_two(
    pkg,
    to_dir = c(
      file.path(pkg$path, "inst", "doc"),
      output_dir
    )
  )

  # get packagedocs vigs
  vigns <- tools::pkgVignettes(dir = pkg$path, output = FALSE, source = FALSE)
  vig_files <- vigns$docs[vigns$engines %in% all_pkgdocs_engines()]
  vig_output_files <- c()
  if (length(vig_files) > 0) {
    message("Building packagedocs vignettes")
    for (vig_file in vig_files) {
      rmarkdown::render(vig_file)
    }

    vig_output_files <- gsub(".Rmd$", ".html", vig_files)
    extra_dirs <- append(extra_dirs, gsub(".Rmd", "_files", vig_files))
    delete_files <- append(delete_files, vig_output_files)

    is_index_redirect <- (vigns$engines == "packagedocs::redirect_index")

    if (any(is_index_redirect)) {
      redirect_vig <- vigns$docs[is_index_redirect]
      if (length(redirect_vig) > 1) {
        message("Multiple packagedocs::redirect_index vignettes found.  Only the first vignette will be used. c(", paste(basename(redirect_vig), collapse = ", "), ")") # nolint
        redirect_vig <- redirect_vig[1]
      }

      from_file <- gsub("Rmd$", "html", redirect_vig)
      to_file <- file.path(dirname(from_file), "index.html")

      message("Renaming ", basename(from_file), " to ", basename(to_file))
      vig_output_files[vig_output_files == from_file] <- file.path(dirname(from_file), "index.html")
      delete_files[delete_files == from_file] <- to_file
      delete_files <- append(delete_files, file.path(output_dir, basename(from_file)))
      file.rename(from_file, to_file)
    }

  }

  # copy packagedocs vigs
  if (length(vig_output_files) > 0) {
    message("Copying packagedocs vigenttes to ", output_dir, ": ", paste(basename(vig_output_files), collapse = ", ")) # nolint
    file.copy(vig_output_files, output_dir, recursive = TRUE)
  }

  # copy extra files
  extra_dir_files <- c()
  for (dir_val in extra_dirs) {
    if (dir.exists(dir_val)) {
      extra_dir_files <- append(extra_dir_files, dir_val)
    }
  }
  extra_dir_files <- unique(extra_dir_files)
  if (length(extra_dir_files) > 0) {
    message(
      "Copying extra files: ", paste(basename(extra_dir_files), collapse = ", "),
      " to ", output_dir
    )
    file.copy(extra_dir_files, output_dir, recursive = TRUE)
  }


  invisible(TRUE)
}
