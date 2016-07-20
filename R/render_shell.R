


render_shell <- function(code_path, output_file_html, is_rd_shell = FALSE) {
  shell_templ <- paste(readLines(file.path(system.file(package = "packagedocs"),
    "rd_template", "shell_template.html")), collapse = "\n")

  pkg_info <- as_sd_package(code_path, run_examples = FALSE)

  github_ref <- parse_github_ref_val(pkg_info)
  if (is.null(github_ref)) {
    stop("There must be a github url in the description to produce a shell vignette")
  }
  user_repo <- strsplit(github_ref, "/")[[1]]

  shell_args = list(
    title = paste0(pkg_info$package, ifelse(is_rd_shell, " package documentation", " function reference")),
    url = paste0("https://", user_repo[1], ".github.io/", user_repo[2], ifelse(is_rd_shell, "/rd.html", ""))
  )
  res <- whisker.render(shell_templ, shell_args)

  cat(res, file = output_file_html)
  cat("\n", file = output_file_html, append = TRUE)

  output_file_html
}