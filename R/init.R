
index_file_rmd <- function() {
  "index.Rmd"
}
index_file_html <- function() {
  "index.html"
}

rd_file_rmd <- function() {
  "rd.Rmd"
}
rd_file_html <- function() {
  "rd.html"
}
rd_temp_file_rmd <- function() {
  "_rd.Rmd"
}

rd_index_file_yaml <- function() {
  "rd_index.yaml"
}

assets_dir <- function() {
  "assets"
}
rd_img_dir <- function() {
  "rd_img"
}
rd_files_dir <- function() {
  "rd_files"
}
index_files_dir <- function() {
  "index_files"
}
lazy_widgets_dir <- function() {
  "lazy_widgets"
}



#' Initialize a new packagedocs project
#'
#' @param code_path location of R package (defaults to current directory)
# ' @param docs_path location of code directory (defaults to a directory "docs" inside \code{code_path})
# ' @param package_name the name of the package, e.g. "packagedocs" (will search in DESCRIPTION if NULL)
#' @param title title of main page (will search in DESCRIPTION if NULL - can be changed later)
#' @param subtitle subtitle of main page (can be changed later)
#' @param author author (can be changed later)
# ' @param github_ref the "user/repo" part of a link to github - if NULL or "", the github link will not be displayed
# ' @param index_file_rmd name of index file to be created
# ' @param rd_file_rmd name of rd file to be created
# ' @param build_file boolean to determine if the build file should be produced
#' @export
init_vignettes <- function(
  code_path = ".",
  title = NULL,
  subtitle = NULL,
  author = NULL
) {

  docs_path <- file.path(code_path, "vignettes")
  index_file_rmd <- index_file_rmd()
  rd_file_rmd <- rd_file_rmd()

  if (file.exists(file.path(docs_path, index_file_rmd))) {
    ans <- readline(paste0("It appears that '", docs_path, "' has already been initialized.  Overwrite ", index_file_rmd, ", ", rd_file_rmd, ", and rd_index.yaml? (y = yes) ", sep = "")) # nolint
    if (!tolower(substr(ans, 1, 1)) == "y") {
      stop("Backing out...", call. = FALSE)
    }
  }

  rd_info <- as_sd_package(code_path)

  package_name <- if_null(rd_info$package, "mypackage")
  title <- if_null(title, package_name)
  subtitle <- if_null(subtitle, rd_info$title)
  author <- parse_author_info(rd_info, author)
  github_ref <- parse_github_ref(rd_info, NULL)


  if (!file.exists(docs_path)) {
    dir.create(docs_path, recursive = TRUE)
  }

  ## index.Rmd
  ##---------------------------------------------------------
  index_template <- init_skeleton("skeleton.Rmd")
  args <- list(
    title = title,
    subtitle = subtitle,
    author = author,
    github_ref = github_ref,
    vig_text = paste(
      "  %\\VignetteIndexEntry{", package_name, "}\n",
      "  %\\VignetteEngine{packagedocs::index}",
      sep = ""
    )
  )
  cat(whisker::whisker.render(index_template, args),
    file = file.path(docs_path, index_file_rmd))

  ## rd_skeleton.Rmd
  ##---------------------------------------------------------
  rd_template <- init_skeleton("rd_skeleton.Rmd")
  args <- list(
    title = title,
    subtitle = subtitle,
    author = author,
    github_ref = github_ref,
    vig_text = paste(
      "  %\\VignetteIndexEntry{", package_name, "_rd}\n",
      "  %\\VignetteEngine{packagedocs::rd}",
      sep = ""
    )
  )
  cat(whisker::whisker.render(rd_template, args),
    file = file.path(docs_path, rd_file_rmd))
  cat("\n", file = file.path(docs_path, rd_file_rmd), append = TRUE)

  ### do not include the yaml file to be copied over
  # ## install extras for devtools
  # install_extras <- file.path(docs_path, ".install_extras")
  # if (file.exists(install_extras)) {
  #   if (! "rd_index.yaml" %in% readLines(install_extras)) {
  #     cat("rd_index.yaml\n", file = install_extras, append = TRUE)
  #   }
  # } else {
  #   cat("rd_index.yaml\n", file = install_extras)
  # }



  # ## build.R
  # ##---------------------------------------------------------
  # if (identical(build_file, TRUE)) {
  #   build_template <- init_skeleton("build.R")
  #   args <- list(
  #     package_name = package_name,
  #     code_path = code_path,
  #     docs_path = docs_path
  #   )
  #   cat(whisker::whisker.render(build_template, args),
  #     file = file.path(docs_path, "build.R"))
  # }

  ## rd_index.yaml
  ##---------------------------------------------------------
  yaml_template <- init_skeleton("rd_index.yaml")

  code_path %>%
    as_sd_package() %>%
    group_fn_by_keyword("Package Functions") ->
  man_info

  args <- list(
    package_name = package_name,
    has_man_info = !is.null(man_info),
    man_info = man_info,
    has_keywords = length(man_info) > 1
  )

  cat(whisker::whisker.render(yaml_template, args),
    file = file.path(docs_path, rd_index_file_yaml()))

  docs <- c(index_file_rmd, rd_file_rmd, rd_index_file_yaml())
  # if (build_file) {
  #   docs <- append(docs, "build.R")
  # }

  message("* packagedocs initialized in ", docs_path)
  message(paste0("* take a look at newly created documents: ", paste(docs, collapse = ", "))) # nolint
}



parse_author_info <- function(rd_info, given_value) {
  author <- given_value
  if (is.null(author)) {
    if (! is.null(rd_info[["authors@r"]])) {
      # parse the authors @ r section for the creator
      author_info <- eval(parse(text = rd_info[["authors@r"]]))
      is_creator <- unlist(lapply(author_info$role, function(roles) {
        "cre" %in% roles
      }))
      author <- author_info[[is_creator]]
    } else {
      # maintainer is a mandatory field if authors@R is not there
      author <- rd_info$maintainer[1]
    }
    author <- gsub(" <[^<]*$", "", author)
  }
  author <- if_null(author, "author")
  if (length(author) == 0) {
    author <- "author"
  }
  author
}


parse_github_ref_val <- function(rd_info, default_value = NULL) {
  if (is.null(default_value)) {
    if (! is.null(rd_info$urls)) {
      has_github_url <- grepl("github\\.com\\/([^\\/]*\\/[^\\/]*)", rd_info$urls)
      if (any(has_github_url)) {
        ans <- gsub(
          ".*github\\.com\\/([^\\/]*\\/[^\\/]*).*",
          "\\1",
          rd_info$urls[has_github_url]
        )
        return(ans)
      }
    }
  }
  default_value
}
parse_github_ref <- function(rd_info, github_ref) {
  # retrieve the github url if nothing else has been specified

  github_val <- parse_github_ref_val(rd_info, github_ref)
  github_val <- if_null(github_val, "")

  if (nchar(github_val) > 0) {
    github_val <- sprintf("\n  <li><a href='https://github.com/%s'>Github <i class='fa fa-github'></i></a></li>", github_val) # nolint
  }

  github_val
}



init_skeleton <- function(filename) {
  paste(readLines(
    file.path(
      system.file(package = "packagedocs"),
      "rmarkdown",
      "templates",
      "packagedocs",
      "skeleton",
      filename
    )
  ), collapse = "\n")
}
