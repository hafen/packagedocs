#' Initialize a new packagedocs project
#'
#' @param code_path location of docs directory
#' @param docs_path location of code directory (defaults to a directory "docs" inside \code{code_path})
#' @param package_name the name of the package, e.g. "packagedocs" (will search in DESCRIPTION if NULL)
#' @param title title of main page (will search in DESCRIPTION if NULL - can be changed later)
#' @param subtitle subtitle of main page (can be changed later)
#' @param author author (can be changed later)
#' @param github_ref the "user/repo" part of a link to github - if NULL or "", the github link will not be displayed
#' @export
packagedocs_init <- function(
  code_path = ".",
  docs_path = file.path(code_path, "docs"),
  package_name = NULL,
  title = NULL, subtitle = "",
  author = NULL, github_ref = "user/repo"
) {

  if (file.exists(file.path(docs_path, "index.Rmd"))) {
    ans <- readline(paste0("It appears that '", docs_path, "' has already been initialized.  Overwrite index.Rmd, rd_skeleton.Rmd, rd_index.yaml, and build.R? (y = yes) ", sep = ""))
    if (!tolower(substr(ans, 1, 1)) == "y") {
      stop("Backing out...", call. = FALSE)
    }
  }

  desc <- NULL
  if (file.exists(file.path(code_path, "DESCRIPTION")))
    desc <- packageDescription(".", code_path)

  if (is.null(package_name)) {
    if (is.null(desc)) {
      package_name <- "mypackage"
    } else {
      package_name <- desc$Package
    }
  }

  if (is.null(author)) {
    if (is.null(desc)) {
      author <- "author"
    } else {
      # probably can be improved...
      author <- gsub("\"([A-Za-z ]+).*", "\\1", desc$Authors[1])
    }
  }

  if (is.null(title)) {
    title <- package_name
  }

  if (is.null(github_ref))
    github_ref <- ""

  if (nchar(github_ref) > 0)
    github_ref <- sprintf("\n  <li><a href='https://github.com/%s'>Github <i class='fa fa-github'></i></a></li>", github_ref)

  if (!file.exists(docs_path))
    dir.create(docs_path)

  ## index.Rmd
  ##---------------------------------------------------------
  skeleton_file_lines <- function(filename, package = "packagedocs") {
    paste(readLines(
      file.path(
        system.file(package = package),
        "rmarkdown",
        "templates",
        "packagedocs",
        "skeleton",
        filename
      )
    ), collapse = "\n")
  }

  index_template <- skeleton_file_lines("skeleton.Rmd")

  args <- list(
    title = title,
    subtitle = subtitle,
    author = author,
    github_ref = github_ref
  )

  cat(whisker::whisker.render(index_template, args),
    file = file.path(docs_path, "index.Rmd"))

  ## rd_skeleton.Rmd
  ##---------------------------------------------------------

  rd_template <- skeleton_file_lines("rd_skeleton.Rmd")

  args <- list(
    title = title,
    subtitle = subtitle,
    author = author,
    github_ref = github_ref
  )

  cat(whisker::whisker.render(rd_template, args),
    file = file.path(docs_path, "rd_skeleton.Rmd"))

  ## build.R
  ##---------------------------------------------------------

  build_template <- skeleton_file_lines("build.R")

  args <- list(
    package_name = package_name,
    code_path = code_path,
    docs_path = docs_path
  )

  cat(whisker::whisker.render(build_template, args),
    file = file.path(docs_path, "build.R"))

  ## rd_index.yaml
  ##---------------------------------------------------------

  yaml_template <- skeleton_file_lines("rd_index.yaml")

  args <- list(
    package_name = package_name
  )

  cat(whisker::whisker.render(yaml_template, args),
    file = file.path(docs_path, "rd_index.yaml"))

  message("* packagedocs initialized in ", docs_path)
  message("* take a look at newly created documents: index.Rmd, rd_skeleton.Rmd, rd_index.yaml, build.R")
}
