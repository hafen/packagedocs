

# direct copy of copy_vignettes from devtools
# added doc_dir as arg
# added extra_files to have dirs lib_dir, "index_files", and "rd_files"
copy_vignettes <- function (pkg, doc_dir = file.path(devtools::as.package(pkg)$path, "inst", "doc"), lib_dir = "assets")
{
  pkg <- devtools::as.package(pkg)

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
  invisible()
}


# Direct copy from devtools::build_vignettes with the addition of the arg 'clean'
build_vignettes <- function (
  pkg = ".",
  dependencies = "VignetteBuilder",
  clean = TRUE,
  output_dir = file.path(devtools::as.package(pkg)$path, "inst", "doc")
) {
    pkg <- devtools::as.package(pkg)
    vigns <- tools::pkgVignettes(dir = pkg$path)
    if (length(vigns$docs) == 0) {
      return()
    }
    devtools::install_deps(pkg, dependencies, upgrade = FALSE)
    message("Building ", pkg$package, " vignettes")
    tools::buildVignettes(dir = pkg$path, tangle = TRUE, clean = clean)
    packagedocs:::copy_vignettes(pkg, doc_dir = output_dir)
    invisible(TRUE)
}
