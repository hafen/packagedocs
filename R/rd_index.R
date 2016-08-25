

as_rd_index <- function(rd_index, run_examples) {

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
