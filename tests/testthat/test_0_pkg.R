


source("pkg_paths.R")


context("init")


test_that("init", {

  if (dir.exists(pkg_path)) {
    # unlink(pkg_path, recursive = TRUE)
  }

  dir.create(pkg_path)
  file.copy(
    pkg_path_original,
    pkg_path_short,
    recursive = TRUE
  )

  init_output <- capture.output({
    packagedocs::init(pkg_path)
  })


  init_output_match <- c(
    "* Adding `inst/doc` to ./.gitignore",
    "* Adding `_gh-pages` to ./.gitignore",
    "* packagedocs initialized in tests/testthat/testpkg/vignettes",
    "* take a look at newly created vignette documents: docs.Rmd, rd.Rmd, rd_index.yaml"
  )

  expect_equal(init_output, init_output_match)

})
