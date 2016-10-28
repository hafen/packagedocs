

as_rd_index <- function(rd_index) {

  topic_pos <- 1
  knitr_args <- rd_index$knitr

  sections <- rd_index$sections

  if (is.null(knitr_args)) {
    knitr_args <- list()
  }

  if (is.null(sections)) {
    stop("'sections' must be defined in the rd_index.yaml file")
  }

  sections %>%
    seq_along() %>%
    lapply(function(section_num) {
      section <- sections[[section_num]]
      section_name <- section$section_name
      if (is.null(section_name)) {
        stop(paste0("section name must be provided for each section of the rd_index file. Error in section: ", section_num)) # nolint
      }

      topics <- section$topics

      topics %>%
        seq_along() %>%
        lapply(function(topic_num) {
          topic <- topics[[topic_num]]
          if (is.character(topic)) {
            topic <- list(title = topic)
          }
          if (is.null(topic$title)) {
            if (!is.null(topic$file)) {
              topic$title <- gsub("\\.Rd", "", topic$file)
            } else {
              stop(paste0("'title' must be provided within each topic (unless a single string). Error in section: ", section_name, ", topic: ", topic_num)) # nolint
            }
          }
          if (is.null(topic$file)) {
            topic$file <- paste(topic$title, ".Rd", sep = "")
          }
          if (is.null(topic$knitr)) {
            topic$knitr <- knitr_args
          }
          def_val_names <- setdiff(names(knitr_args), names(topic$knitr))
          if (length(def_val_names) > 0) {
            topic$knitr[def_val_names] <- knitr_args[def_val_names]
          }

          topic$index_id <- paste0("id_", topic_pos)
          topic_pos <<- topic_pos + 1

          topic
        }) ->
      topics

      # set the topics object name to be the file name
      names(topics) <- lapply(topics, "[[", "file") %>% unlist()

      list(section_name = section_name, topics = topics)
    })
}


display_current_rd_index <- function(rd_index) {
  rd_index %>%
    lapply(function(section_info) {
      section_info$topics %>%
        unname() %>%
        lapply(function(topic) {
          topic$index_id <- NULL
          topic
        }) ->
      section_info$topics
      section_info
    }) %>%
    yaml::as.yaml() ->
  yaml_output

  message("\nrd_index yaml file to be used: \n", yaml_output)
  invisible()
}

#' Check rd_index.yaml for missing or extra topics
#'
#' @param code_path path to the source code directory of the package
#' @param rd_info used internally - do not specify if called interactively
#' @param rd_index used internally - do not specify if called interactively
#' @export
check_rd_index <- function(code_path = ".", rd_info = NULL, rd_index = NULL) {

  if (is.null(rd_info))
    rd_info <- as_sd_package(code_path)

  if (is.null(rd_index)) {
    rd_index_file <- "rd_index.yaml"
    # this function can either be called by the user interactively
    # or from when it the vignettes are being built
    # in the case of vignettes, the working directory will be vignettes
    # otherwise, if it is interactive, use code_path
    if (!file.exists(rd_index_file)) {
      rd_index_file <- file.path(code_path, "vignettes/rd_index.yaml")
      if (!file.exists(rd_index_file))
        stop("The file ", rd_index_file, " could not be found:\n",
          geterrmessage())
    }
    rd_index <- try(yaml.load_file(rd_index_file) %>% as_rd_index(), silent = TRUE)
    if (inherits(rd_index, "try-error")) {
      stop("There was an error reading ", rd_index_file, ":\n",
        geterrmessage())
    }
  }

  # get all rd files from the rd_index topics
  rd_files <- alias_files_from_index(rd_index)

  missing_topics <- setdiff(rd_info$rd_index$file_in, rd_files)
  if (length(missing_topics) > 0) {
    message(
      "*** topics in package that were not found in rd_index (will not be included): ",
      paste(missing_topics, collapse = ", ")
    )
  }

  unknown_topics <- setdiff(rd_files, rd_info$rd_index$file_in)
  if (length(unknown_topics) > 0) {
    message(
      "*** topics found in rd_index that aren't in package (will not be included): ",
      paste(unknown_topics, collapse = ", ")
    )
    unknown_ids <- rd_files[rd_files %in% unknown_topics] %>% names()
    rd_index <- remove_topics_from_index(rd_index, unknown_ids)
  }
}
