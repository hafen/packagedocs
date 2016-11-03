

source("pkg_paths.R")


context("delete package")

test_that("delete package", {

  if (dir.exists(pkg_path_short)) {
    unlink(pkg_path_short, recursive = TRUE)
  }

  expect_true(!dir.exists(pkg_path_short))
})
