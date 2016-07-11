

as_rd_index <- function(rd_index) {
  rd_index %>%
    seq_along() %>%
    lapply(function(section_num) {
      section <- rd_index[[section_num]]
      section_name <- section$section_name
      if (is.null(section_name)) {
        stop(paste0("section name must be provided for each section fo the rd_index file. Error in section: ", section_num)) # nolint
      }

      topics <- section$topics

      if (!is.list(topics)) {
        topics %>%
          lapply(function(topic) {
            list(
              file = paste(topic, ".Rd", sep = ""),
              title = topic
            )
          }) ->
        topics
      } else {
        topics %>%
          seq_along() %>%
          lapply(function(topic_num) {
            topic <- topics[[topic_num]]
            if (is.character(topic)) {
              topic <- list(file = paste(topic, ".Rd", sep = ""), title = topic)
            }
            file = topic$file
            if (is.null(file)) {
              stop(paste0("'file' must be provided within each topic (unless a single string). Error in section: ", section_num, ", topic: ", topic_num)) # nolint
            }
            title = topic$title
            if (is.null(file)) {
              stop(paste0("'title' must be provided within each topic (unless a single string). Error in section: ", section_num, ", topic: ", topic_num)) # nolint
            }
            topic
          }) ->
        topics
      }

      list(section_name = section_name, topics = topics)
    })
}
