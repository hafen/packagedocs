

as_sd_package <- function(pkg_path, site_path = "./") {
  if (! dir.exists(site_path)) {
    dir.create(site_path)
  }
  rd_info <- as.sd_package(
    pkg_path,
    examples = FALSE,
    site_path = site_path
  )
  names(rd_info$rd_index$alias) <- rd_info$rd_index$file_in

  rd_info$example_text <- lapply(rd_info$rd, function(x) {
    tags <- sapply(x, function(a) attr(a, "Rd_tag"))
    tags <- gsub("\\\\", "", tags)
    if (any(tags == "examples")) {
      # get the example and remove the first item, like to_html.examples
      example_tag <- x[[which(tags == "examples")]]
      to_html.TEXT(example_tag[-1])
    } else {
      NULL
    }
  })

  rd_info
}
