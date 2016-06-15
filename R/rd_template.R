
rd_get_metadata <- getFromNamespace(".Rd_get_metadata", loadNamespace("tools"))
rd_path <- getFromNamespace("rd_path", loadNamespace("staticdocs"))
set_classes <- getFromNamespace("set_classes", loadNamespace("staticdocs"))
to_html_rd_doc <- getFromNamespace("to_html.Rd_doc", loadNamespace("staticdocs"))




#' Generate the text to put in a rd.rmd file to build a package function reference
#'
#' @param package_name the name of the package, e.g. "packagedocs"
#' @param code_path path to the source code directory of the package
#' @param rd_index path to yaml file with index layout information
#' @param exclude vector of Rd entry names to exclude from the resulting document
#' @importFrom tools Rd_db
#' @importFrom whisker whisker.render
#' @importFrom yaml yaml.load_file
#' @import stringr
# @import staticdocs
#' @export
rd_template <- function(package_name, code_path, rd_index = NULL, exclude = NULL) {

  # library(whisker); library(staticdocs); library(tools); library(stringr)
  # exclude <- "pipe"
  # package_name <- "datadr"
  # code_path <- "~/Documents/Code/Tessera/hafen/datadr"

  # db <- Rd_db(package_name)
  # names(db) <- gsub("\\.Rd", "", names(db))

  ## let staticdocs handle this
  # usgs <- lapply(db, function(x) {
  #   tags <- sapply(x, function(a) attr(a, "Rd_tag"))
  #   tags <- gsub("\\\\", "", tags)
  #   ## we may still want usage, even if examples are missing.
  #   if (any(tags == "usage")) {
  #     x <- paste(unlist(x[[which(tags == "usage")]]), collapse = "")
  #     gsub("^[\\n]+|[\\n]+$", "", x, perl = TRUE)
  #   } else {
  #     NULL
  #   }
  # })

  # exs <- lapply(db, function(x) {
  #   tags <- sapply(x, function(a) attr(a, "Rd_tag"))
  #   tags <- gsub("\\\\", "", tags)
  #   if (any(tags == "examples")) {
  #     # TODO: preserve dontrun as separate blocks
  #     # x[[which(tags == "examples")]]
  #     x <- paste(unlist(x[[which(tags == "examples")]]), collapse = "")
  #     gsub("^[\\n]+|[\\n]+$", "", x, perl = TRUE)
  #   } else {
  #     NULL
  #   }
  # })
  # names(exs) <- gsub("\\.Rd$", "", names(exs))

  # use package docs to retrieve everything
  # set examples to FALSE "not evaluate examples"
  # set examples to TRUE to "evaluate examples"
  package <- staticdocs::as.sd_package(code_path, examples = FALSE)
  # name the aliases for easier help later
  names(package$rd_index$alias) <- package$rd_index$file_in

  # nms <- gsub("\\.Rd", "", names(db))
  # want to be able to list all aliases (more functions can exist than .Rd files)
  # nms <- unname(unlist(lapply(db, rd_get_metadata, "alias")))
  nms <- unname(unlist(package$rd_index$alias))

  # Under what conditions do we add `package_name` to exclude?
  # Only of there doesn't exist a function or alias with the same name as the package
  if (!(package_name %in% nms)){
    exclude <- unique(c(exclude, package_name))
  }

  if (!is.null(exclude)){
    message("ignoring: ", paste(exclude, collapse = ", "))
  }

  nms <- setdiff(nms, exclude)

  if (is.null(rd_index)) {
    if (file.exists("rd_index.yaml")) {
      rd_index <- "rd_index.yaml"
    }
  }

  if (!is.null(rd_index)) {
    rd_index <- yaml.load_file(rd_index)
    rd_topics <- unlist(lapply(rd_index, function(x) {
      res <- try(x$topics, silent = TRUE)
      if (inherits(res, "try-error"))
        stop("error in rd index yaml file - not a valid section", call. = FALSE)
      res
    }))
    missing_topics <- setdiff(nms, rd_topics)
    if (length(missing_topics) > 0) {
      message(
        "topics in package that were not found in rd_index (will not be included): ",
        paste(missing_topics, collapse = ", ")
      )
      nms <- setdiff(nms, missing_topics)
    }
    unknown_topics <- setdiff(rd_topics, nms)
    if (length(unknown_topics) > 0) {
      message(
        "topics found in rd_index that aren't in package (will not be included): ",
        paste(unknown_topics, collapse = ", ")
      )
      for (ii in seq_along(rd_index))
        rd_index[[ii]]$topics <- setdiff(rd_index[[ii]]$topics, unknown_topics)
    }
  } else {
    rd_index <- list(list(section_name = "Package", desc = "", topics = sort(nms)))
  }

  dat <- list(
     title = package$title,
     version = package$version,
     description = package$description,
     license = package$license,
     depends = package$depends,
     imports = package$imports,
     suggests = package$suggests,
     enhances = package$enhances,
     author = package$authors
  )

  for (ii in seq_along(dat)) {
    if (is.null(dat[[ii]]))
      dat[[ii]] <- "(none)"
  }

  main_template <- paste(readLines(file.path(system.file(package = "packagedocs"),
    "rd_template", "rd_main_template.Rmd")), collapse = "\n")
  rd_template <- paste(readLines(file.path(system.file(package = "packagedocs"),
    "rd_template", "rd_template.Rmd")), collapse = "\n")

  entries <- lapply(nms, function(nm) {
    try(get_rd_data(nm, package_name, package, exs, usgs))
  })

  idx <- which(sapply(entries, function(x) inherits(x, "try-error")))
  if (length(idx) > 0) {
    error_topics <- nms[idx]
    message(
      "there were errors running the following topics (will be removed): ",
      paste(error_topics, collapse = ", ")
    )
    entries <- entries[-idx]
    nms <- nms[-idx]
    for (ii in seq_along(rd_index))
      rd_index[[ii]]$topics <- setdiff(rd_index[[ii]]$topics, error_topics)
  }

  names(entries) <- nms

  tmp <- entries[[paste(package_name, "package", sep = "-")]]
  if (!is.null(tmp)) {
    dat$description <- tmp$description
  }

  main <- whisker.render(main_template, dat)

  for (ii in seq_along(rd_index))
    rd_index[[ii]]$entries <- unname(entries[rd_index[[ii]]$topics])
  all_entries <- whisker.render(rd_template, rd_index)

  res <- paste(c(main, all_entries), collapse = "\n")
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

get_rd_data <- function(nm, package_name, package, exs, usgs) {
  cat(nm, "\n")

  # get_help_file <- getFromNamespace(".getHelpFile", loadNamespace("utils"))
  # b <- get_help_file(rd_path(nm, package_name))

  # map to help file name
  help_name <- names(which(sapply(package$rd_index$alias, function(aliases) {
    nm %in% aliases
  })))
  # use staticdocs package output
  b <- package$rd[[help_name]]
  if (is.null(b)) {
    stop("Package help file can't be found")
  }

  # b <- structure(set_classes(b), class = "Rd_content")
  # attr(b, "Rd_tag") <- "Rd file"

  # use to_html.rd_doc to convert nicely to a list
  data <- to_html_rd_doc(b, pkg = package)

  data$examples <- exs[[nm]]
  # data$examples <- exs[[nm]]
  ## to_html does a good job of getting usage.
  # data$usage <- usgs[[nm]]

  data$id <- valid_id(nm)
  # data$name <- nm

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
  if (length(zero_ind) > 0)
    data$sections <- data$sections[-zero_ind]

  # rgxp <- "([a-zA-Z0-9\\.\\_]+)\\.html"


  # replace seealso links with hashes
  data$seealso <- fix_hrefs(data$seealso)

  # same for usage
  # data$usage <- fix_hrefs(data$usage)
  # data$usage <- gsub("\\n    ", "\n  ", data$usage)

  for (jj in seq_along(data$sections)) {
    if ("contents" %in% names(data$sections[[jj]]))
      data$sections[[jj]]$contents <- fix_hrefs(data$sections[[jj]]$contents)
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
