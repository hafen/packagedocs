


source("pkg_paths.R")


context("init")


test_that("init", {

  if (dir.exists(pkg_path_short)) {
    unlink(pkg_path_short, recursive = TRUE)
  }

  dir.create(pkg_path_short, showWarnings = FALSE)
  file.copy(
    pkg_path_original,
    pkg_path_short,
    recursive = TRUE
  )


  expect_message({
    init_vignettes(pkg_path)
  })

  match_yaml <- yaml::yaml.load_file("match.yaml")
  test_yaml <- yaml::yaml.load_file(file.path(pkg_path, "vignettes", "rd_index.yaml"))
  expect_equal(test_yaml, match_yaml)

  expect_true(!dir.exists(file.path(pkg_path, "_gh-pages")))

  output <- capture.output({
    build_vignettes(pkg_path)
  })
  expect_true(length(output) > 0)

  expect_true(dir.exists(file.path(pkg_path, "_gh-pages")))


})
