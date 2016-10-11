
#' Read .Rmd yaml header
#'
#' @param file input file to read
#' @export
read_rmd_yaml <- function(file) {
  input_lines <- readLines(file)
  from_to <- which(grepl("^---$", input_lines))[1:2]
  from_to <- from_to + c(1, -1)
  yaml_txt <- paste(input_lines[seq(from_to[1], from_to[2])], collapse = "\n")
  yaml::yaml.load(yaml_txt)
}


render_redirect <- function(input_file_rmd, output_file_html) {

  input_yaml <- read_rmd_yaml(input_file_rmd)


  redirect_url <- input_yaml$packagedocs_redirect
  if (is.null(redirect_url)) {
    stop("key 'packagedocs_redirect' must be located in the .Rmd header")
  }
  title <- input_yaml$title
  if (is.null(title)) {
    stop("key 'title' must be located in the .Rmd header")
  }

  cran_templ <- paste(readLines(file.path(system.file(package = "packagedocs"),
    "rd_template", "cran_template.html")), collapse = "\n")
  res <- whisker.render(cran_templ, list(title = title, url = redirect_url))

  cat(res, file = output_file_html)
  cat("\n", file = output_file_html, append = TRUE)

  output_file_html
}
