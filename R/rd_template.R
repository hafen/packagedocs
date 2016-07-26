
rd_get_metadata <- getFromNamespace(".Rd_get_metadata", loadNamespace("tools"))
rd_path <- getFromNamespace("rd_path", loadNamespace("staticdocs"))
set_classes <- getFromNamespace("set_classes", loadNamespace("staticdocs"))
to_html_rd_doc <- getFromNamespace("to_html.Rd_doc", loadNamespace("staticdocs"))




#' Generate the text to put in a rd.rmd file to build a package function reference
#'
#' @param code_path path to the source code directory of the package
#' @param rd_index path to yaml file with index layout information
#' @param exclude vector of Rd entry names to exclude from the resulting document
#' @param run_examples boolean to determine if examples should be run
#' @param img_path directory where all evaluated images should be saved
#' @importFrom magrittr set_names
#' @importFrom tools Rd_db
#' @importFrom whisker whisker.render
#' @importFrom yaml yaml.load_file
#' @import stringr
# @import staticdocs
#' @export
rd_template <- function(code_path, rd_index = NULL, exclude = NULL, run_examples = FALSE, img_path = rd_img_dir()) {

  if (!dir.exists(img_path)) {
    dir.create(img_path)
  }
  rd_info <- as_sd_package(code_path)
  on.exit({
    # if no images exist, delete the folder
    if (length(dir(img_path)) == 0) {
      unlink(img_path)
    }
  })

  # This should be done in init
    # # Under what conditions do we add `package_name` to exclude?
    # # Only of there doesn't exist a function or alias with the same name as the package
    # if (!(package_name %in% nms)){
    #   exclude <- unique(c(exclude, package_name))
    # }
    #
    # if (!is.null(exclude)){
    #   message("ignoring: ", paste(exclude, collapse = ", "))
    # }
    # nms <- setdiff(nms, exclude)

  if (is.null(rd_index)) {
    if (file.exists(rd_index_file_yaml())) {
      rd_index <- rd_index_file_yaml()
    }
  }

  if (is.null(rd_index)) {
    rd_index <- list(
      list(
        section_name = "Package Functions",
        desc = "",
        topics = gsub("\\.Rd", "", rd_info$rd_index$file_in)
      )
    )
  } else {
    rd_index <- yaml.load_file(rd_index)
  }

  rd_index <- as_rd_index(rd_index)

  # get all rd files from the rd_index topics
  rd_files <- alias_files_from_index(rd_index)

  missing_topics <- setdiff(rd_info$rd_index$file_in, rd_files)
  if (length(missing_topics) > 0) {
    message(
      "topics in package that were not found in rd_index (will not be included): ",
      paste(missing_topics, collapse = ", ")
    )
  }

  unknown_topics <- setdiff(rd_files, rd_info$rd_index$file_in)
  if (length(unknown_topics) > 0) {
    message(
      "topics found in rd_index that aren't in package (will not be included): ",
      paste(unknown_topics, collapse = ", ")
    )
    rd_index <- remove_topics_from_index(rd_index, unknown_topics)
  }

  # allow for null values as they will not be displayed
  dat <- list(
    title = rd_info$title,
    version = rd_info$version,
    description = rd_info$description,
    license = rd_info$license,
    depends = rd_info$depends,
    imports = rd_info$imports,
    suggests = rd_info$suggests,
    enhances = rd_info$enhances,
    author = rd_info$authors
  )

  main_templ <- paste(readLines(file.path(system.file(package = "packagedocs"),
    "rd_template", "rd_main_template.Rmd")), collapse = "\n")
  rd_templ <- paste(readLines(file.path(system.file(package = "packagedocs"),
    "rd_template", "rd_template.Rmd")), collapse = "\n")

  title_map <- title_map_from_index(rd_index)
  entries_rd_file <- rd_info$rd_index$file_in
  entries <- lapply(entries_rd_file, function(alias_file) {
    try(get_rd_data(
      alias_file, rd_info,
      title = title_map[[alias_file]],
      img_path = img_path,
      run_examples = run_examples
    ))
  }) %>%
    set_names(entries_rd_file)

  idx <- which(
    as.logical(unlist(
      sapply(entries, function(x) inherits(x, "try-error"))
    ))
  )

  if (length(idx) > 0) {
    rd_files <- alias_files_from_index(rd_index)
    error_topics <- entries_rd_file[idx]
    error_topics <- error_topics[error_topics %in% rd_files]
    if (length(error_topics) > 0) {
      message(
        "there were errors running the following topics (will be removed): ",
        paste(error_topics, collapse = ", ")
      )
      rd_index <- remove_topics_from_index(rd_index, error_topics)
    }
  }

  tmp <- entries[[paste(rd_info$package, "-package", sep = "")]]
  if (!is.null(tmp)) {
    dat$description <- tmp$description
  }

  main <- whisker.render(main_templ, dat)

  for (ii in seq_along(rd_index)) {
    ii_files <- alias_files_from_topics(rd_index[[ii]]$topics)
    rd_index[[ii]]$entries <- unname(entries[ii_files])
  }
  all_entries <- whisker.render(rd_templ, rd_index)

  package_load <- paste("
  ```{r echo=FALSE}
  suppressWarnings(suppressMessages(library(", rd_info$package, ")))
  ```
  ", sep = "")

  res <- paste(c(main, package_load, all_entries), collapse = "\n")
  gsub("<code>\n", "<code>", res)
}

valid_id <- function(x) {
   # x <- gsub(" ", "-", x)
   # tolower(gsub("[^0-9a-zA-Z\\-]+", "", x))
  x
}

# to avoid gsubfn
fix_hrefs <- function(x) {
  tmp <- strsplit(x, "'")
  unlist(lapply(tmp, function(a) {
    idx <- which(grepl("\\.html$", a))
    a[idx] <- paste0("#", tolower(gsub("\\.html", "", a[idx])))
    paste(a, collapse = "")
  }))
}

get_rd_data <- function(alias_file, rd_info, title, img_path, run_examples) {

  # use staticdocs package output
  rd_obj <- rd_info$rd[[alias_file]]
  if (is.null(rd_obj)) {
    stop("Package help file can't be found")
  }

  # use to_html.rd_doc to convert nicely to a list
  data <- to_html_rd_doc(rd_obj, pkg = rd_info, topic = file.path(img_path, "pic"))

  data$examples <- rd_info$example_text[[alias_file]]
  data$example_name <- gsub("\\.Rd", "", alias_file)
  data$eval_example <- ifelse(run_examples, "TRUE", "FALSE")

  name <- gsub("\\.Rd", "", alias_file)
  data$id <- valid_id(name)
  data$name <- if_null(title, name)

  # if (runif(1) < 0.1) {
  #   stop("asdfasdf")
  # }

  desc_ind <- which(sapply(data$sections, function(a) {
    if (!is.null(names(a))) {
      if ("title" %in% names(a)) {
        if (a$title == "Description")
          return(TRUE)
      }
    }
    FALSE
  }))

  if (length(desc_ind) > 0) {
    data$description <- data$sections[[desc_ind]]$contents
    data$sections[[desc_ind]] <- NULL
  }

  zero_ind <- which(sapply(data$sections, length) == 0)
  if (length(zero_ind) > 0) {
    data$sections <- data$sections[-zero_ind]
  }

  # rgxp <- "([a-zA-Z0-9\\.\\_]+)\\.html"

  # replace seealso links with hashes
  data$seealso <- fix_hrefs(data$seealso)

  # same for usage
  # data$usage <- fix_hrefs(data$usage)
  # data$usage <- gsub("\\n    ", "\n  ", data$usage)

  for (jj in seq_along(data$sections)) {
    if ("contents" %in% names(data$sections[[jj]])) {
      data$sections[[jj]]$contents <- fix_hrefs(data$sections[[jj]]$contents)
    }
  }
  # "#\\L\\1"

  for (jj in seq_along(data$arguments)) {
    data$arguments[[jj]]$description <- fix_hrefs(data$arguments[[jj]]$description)
  }

  ## other sections assume description to be of length 1
  if (!is.null(data$description)) {
    data$description <- paste(data$description, collapse = "\n")
  }

    ## assuming description may have multiple sentences
  if (data$title == data$description[1]) {
    data$description <- NULL
  }

  data
}


remove_topics_from_index <- function(rd_index, bad_topics) {

  # by going in rev order, sections may be removed without worry
  messages <- c()
  for (ii in rev(seq_along(rd_index))) {
    ii_files <- alias_files_from_topics(rd_index[[ii]]$topics)
    rd_index[[ii]]$topics <- rd_index[[ii]]$topics [
      ! (ii_files %in% bad_topics)
    ]

    if (length(rd_index[[ii]]$topics) == 0) {
      messages <- append(messages,
        paste0("Removing section: \"", rd_index[[ii]]$section_name, "\", due to lack of topics"))
      rd_index <- rd_index[-ii]
    }
  }
  lapply(rev(messages), message)

  rd_index
}


alias_files_from_topics <- function(topic) {
  topic %>%
    lapply("[[", "file") %>%
    unlist()
}
alias_files_from_index <- function(rd_index) {
  rd_index %>%
    lapply("[[", "topics") %>%
    unlist(recursive = FALSE) %>%
    lapply("[[", "file") %>%
    unlist()
}

title_map_from_index <- function(rd_index) {
  alias_files <- alias_files_from_index(rd_index)

  rd_index %>%
    lapply("[[", "topics") %>%
    unlist(recursive = FALSE) %>%
    lapply("[[", "title") %>%
    set_names(alias_files)
}
