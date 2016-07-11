

# path so that staticdocs doesn't get upset
staticdocs_site_path <- tempdir()

as_sd_package <- function(pkg_path, examples = FALSE) {
  rd_info <- staticdocs::as.sd_package(
    pkg_path,
    examples = FALSE,
    site_path = staticdocs_site_path
  )
  names(rd_info$rd_index$alias) <- rd_info$rd_index$file_in
  rd_info
}
