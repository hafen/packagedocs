#' Generate the text to put in a rd.rmd file to build a package function reference
#'
#' @param package_name the name of the package, e.g. "packagedocs"
#' @param code_path path to the source code directory of the package
#' @param exclude vector of Rd entry names to exclude from the resulting document
#' @importFrom tools Rd_db
#' @importFrom whisker whisker.render
#' @import stringr
#' @importFrom gsubfn gsubfn
#' @export
function_ref_template <- function(package_name, code_path, exclude = NULL) {
  options(gsubfn.engine = "R")

  require(staticdocs)

  # library(gsubfn); library(whisker); library(staticdocs); library(tools); library(stringr)
  # exclude <- c("pipe", "scales")
  # package_name <- "rbokeh"
  # code_path <- "~/Documents/Code/rbokeh"

  db <- Rd_db(package_name)

  package <- as.sd_package(code_path, examples = FALSE)

  nms <- names(db)
  nms2 <- gsub("\\.Rd", "", nms)

  exs <- lapply(db, tools:::.Rd_get_metadata, "examples")
  exs <- lapply(exs, function(x) x[2])
  names(exs) <- nms2

  if(!is.null(exclude)) {
    nms2 <- setdiff(nms2, exclude)
    exs <- exs[nms2]
  }

  dat <- list(
     title = package$title,
     version = package$version,
     date = package$date,
     description = package$description,
     license = package$license,
     depends = package$depends,
     suggests = package$suggests,
     author = package[["authors"]]
  )

  main_template <- paste(readLines(file.path(system.file(package = "packagedocs"), "/rd_template/rd_main_template.Rmd")), collapse = "\n")
  rd_template <- paste(readLines(file.path(system.file(package = "packagedocs"), "/rd_template/rd_template.Rmd")), collapse = "\n")

  entries <- lapply(nms2, function(nm) {
    ht <- get_rd_data(nm, package_name, package, exs)
  })
  names(entries) <- nms2

  tmp <- entries[[paste(package_name, "package", sep = "-")]]
  if(!is.null(tmp)) {
    dat$description <- tmp$description
  }

  main <- whisker.render(main_template, dat)
  entries <- sapply(entries,
    function(xx) whisker.render(rd_template, xx))

  res <- paste(c(main, entries), collapse = "\n")
  gsub("<code>\n", "<code>", res)
}

valid_id <- function(x) {
   # x <- gsub(" ", "-", x)
   # tolower(gsub("[^0-9a-zA-Z\\-]+", "", x))
  x
}

fix_usage <- function(u) {
  u <- gsub("<div>", "", u)
  u <- gsub("</div>", "", u)
  u <- gsub("&nbsp;", " ", u)

  str_wrap(u, 60, 0, 2)
}

get_rd_data <- function(nm, package_name, package, exs) {
  cat(nm, "\n")
  b <- parse_rd(nm, package_name)
  data <- to_html(b, pkg = package)

  x <- exs[[nm]]
  if(!is.na(x)) {
    x <- dget(textConnection(x))
    data$examples <- paste(x, collapse = "")
  }

  data$id <- valid_id(data$name)

  desc_ind <- which(sapply(data$sections, function(a) {
    if(!is.null(names(a))) {
      if("title" %in% names(a)) {
        if(a$title == "Description")
          return(TRUE)
      }
    }
    FALSE
  }))

  if(length(desc_ind) > 0) {
    data$description <- data$sections[[desc_ind]]$contents
    data$sections[[desc_ind]] <- NULL
  }

  zero_ind <- which(sapply(data$sections, length) == 0)
  if(length(zero_ind) > 0)
    data$sections <- data$sections[-zero_ind]

  rgxp <- "([a-zA-Z0-9\\.\\_]+)\\.html"


  # replace seealso links with hashes
  data$seealso <- gsubfn(rgxp, ~ paste("#", valid_id(x), sep = ""), data$seealso)

  # same for usage
  data$usage <- gsubfn(rgxp, ~ paste("#", valid_id(x), sep = ""), data$usage)
  # data$usage <- gsub("\\n    ", "\n  ", data$usage)

  for(jj in seq_along(data$sections)) {
    if("contents" %in% names(data$sections[[jj]]))
      data$sections[[jj]]$contents <- gsubfn(rgxp, ~ paste("#", valid_id(x), sep = ""), data$sections[[jj]]$contents)
  }
  # "#\\L\\1"

  for(jj in seq_along(data$arguments)) {
    data$arguments[[jj]]$description <- gsubfn(rgxp, ~ paste("#", valid_id(x), sep = ""), data$arguments[[jj]]$description)
  }

  if(data$title == data$description)
    data$description <- NULL

  data$usage <- fix_usage(data$usage)

  data
}


