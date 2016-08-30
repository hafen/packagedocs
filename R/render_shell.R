


render_cran <- function(code_path, output_file_html, is_rd_cran = FALSE, is_https = FALSE) {
  cran_templ <- paste(readLines(file.path(system.file(package = "packagedocs"),
    "rd_template", "cran_template.html")), collapse = "\n")

  pkg_info <- as_sd_package(code_path)

  github_ref <- parse_github_ref_val(pkg_info)
  if (is.null(github_ref)) {
    stop("There must be a github url in the 'url' field of the DESCRIPTION file ",
      "to produce a CRAN vignette")
  }
  user_repo <- strsplit(github_ref, "/")[[1]]

  http <- ifelse(isTRUE(is_https), "https", "http")

  cran_args <- list(
    title = paste0(
      pkg_info$package,
      ifelse(is_rd_cran, " function reference", " package documentation")
    ),
    url = paste0(
      http, "://", user_repo[1], ".github.io/", user_repo[2],
      ifelse(is_rd_cran, paste("/", output_file_html, sep = ""), "") # nolint
    )
  )
  res <- whisker.render(cran_templ, cran_args)

  cat(res, file = output_file_html)
  cat("\n", file = output_file_html, append = TRUE)

  output_file_html
}
