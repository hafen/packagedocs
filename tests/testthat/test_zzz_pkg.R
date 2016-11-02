

source("pkg_paths.R")


context("delete package")

test_that("delete package", {

  if (dir.exists(pkg_path)) {
    # unlink(pkg_path, recursive = TRUE)
  }

  expect_true(!dir.exists(pkg_path))
})
