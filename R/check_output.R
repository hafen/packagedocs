#' Check output for warnings and errors
#'
#' @param ff path to a .html file output by `render()`
#' @export
check_output <- function(ff) {
  tmp <- readLines(ff)

  idx <- which(grepl("Error", tmp))
  if (length(idx) == 0) {
    message("No errors... Woohoo!")
  } else {
    message("There were ", length(idx), " errors:\n",
      paste("  ", idx, ": ",
        substr(tmp[idx], 1, 50), ifelse(nchar(tmp[idx]) > 50, "...", ""),
        collapse = "\n", sep = ""
      )
    )
  }

  idx <- which(grepl("Warning", tmp))

  if (length(idx) == 0) {
    message("No warnings... Yippee!")
  } else {
    message("There were ", length(idx), " warnings:\n",
      paste("  ", idx, ": ",
        substr(tmp[idx], 1, 50), ifelse(nchar(tmp[idx]) > 50, "...", ""),
        collapse = "\n", sep = ""
      )
    )
  }
}
