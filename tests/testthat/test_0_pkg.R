


source("pkg_paths.R")


context("init")


test_that("init", {

  if (dir.exists(pkg_path)) {
    # unlink(pkg_path, recursive = TRUE)
  }

  file.copy(
    pkg_path_original,
    pkg_path
  )

})
