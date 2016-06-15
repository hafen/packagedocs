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
  author = NULL, github_ref = NULL
) {

  if (file.exists(file.path(docs_path, "index.Rmd"))) {
    ans <- readline(paste0("It appears that '", docs_path, "' has already been initialized.  Overwrite index.Rmd, rd_skeleton.Rmd, rd_index.yaml, and build.R? (y = yes) ", sep = "")) # nolint
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
      if (! is.null(desc[["Authors@R"]])) {
        author_info <- eval(parse(text = desc[["Authors@R"]]))
        is_creator <- unlist(lapply(author_info$role, function(roles) {
          "cre" %in% roles
        }))
        author <- author_info[[is_creator]]
      } else {
        author <- desc$Authors[1]
      }
      author <- gsub("([A-Za-z ]+[A-Za-z]).*", "\\1", author)
    }
  }

  if (is.null(title)) {
    title <- package_name
  }

  github_val <- ""
  if (is.null(github_ref)) {
    if (missing(github_ref)) {
      if (!is.null(desc)) {
        if (! is.null(desc$URL)) {
          has_github_url <- grepl("github\\.com\\/([^\\/]*\\/[^\\/]*)", desc$URL)
          if (has_github_url) {
            github_val <- gsub(".*github\\.com\\/([^\\/]*\\/[^\\/]*).*", "\\1", desc$URL)
          }
        }
      }
    }
  }
  github_ref <- github_val



  if (nchar(github_ref) > 0)
    github_ref <- sprintf("\n  <li><a href='https://github.com/%s'>Github <i class='fa fa-github'></i></a></li>", github_ref) # nolint

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

  man_files <- ""
  has_man_files <- FALSE
  if (!is.null(desc)) {
    # means in package
    man_files <- gsub("\\.Rd", "", basename(dir("man")))
    man_files <- paste("    - ", man_files, sep = "", collapse = "\n")
    has_man_files <- TRUE
  }

  args <- list(
    package_name = package_name,
    man_files = man_files,
    has_man_files = has_man_files
  )

  cat(whisker::whisker.render(yaml_template, args),
    file = file.path(docs_path, "rd_index.yaml"))

  message("* packagedocs initialized in ", docs_path)
  message("* take a look at newly created documents: index.Rmd, rd_skeleton.Rmd, rd_index.yaml, build.R") # nolint
}
