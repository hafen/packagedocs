

as_rd_index <- function(rd_index, run_examples) {

  rd_index %>%
    seq_along() %>%
    lapply(function(section_num) {
      section <- rd_index[[section_num]]
      section_name <- section$section_name
      if (is.null(section_name)) {
        stop(paste0("section name must be provided for each section fo the rd_index file. Error in section: ", section_num)) # nolint
      }

      topics <- section$topics

      topics %>%
        seq_along() %>%
        lapply(function(topic_num) {
          topic <- topics[[topic_num]]
          if (is.character(topic)) {
            topic <- list(title = topic)
            # message("Upgrading section: ", section_name, ", topic: ", topic$title, " title to ", topic$title)
          }
          if (is.null(topic$title)) {
            stop(paste0("'title' must be provided within each topic (unless a single string). Error in section: ", section_name, ", topic: ", topic_num)) # nolint
          }
          if (is.null(topic$file)) {
            topic$file <- paste(topic$title, ".Rd", sep = "")
            # message("Upgrading section: ", section_name, ", topic: ", topic$title, " file name to ", topic$file)
          }
          if (is.null(topic$run_examples)) {
            topic$run_examples <- run_examples
            # message("Upgrading section: ", section_name, ", topic: ", topic$title, " run_examples name to ", topic$run_examples)
          }
          topic
        }) ->
      topics

      # set the topics object name to be the file name
      names(topics) <- lapply(topics, "[[", "file") %>% unlist()

      list(section_name = section_name, topics = topics)
    })
}
