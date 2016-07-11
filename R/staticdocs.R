

as_sd_package = function(pkg_path, docs_path, examples = FALSE) {
  site_path <- file.path(docs_path, "_cache", "staticdocs")
  if (!dir.exists(site_path)) {
    dir.create(site_path, recursive = TRUE)
  }
  rd_info <- staticdocs::as.sd_package(pkg_path, examples = FALSE, site_path = site_path)
  names(rd_info$rd_index$alias) <- rd_info$rd_index$file_in
  rd_info
}
