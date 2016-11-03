

source("pkg_paths.R")

context("rd_link")

test_that("links", {

  # info <- capture.output(dput(list(
  #   pwd = getwd(),
  #   dir0 = dir(),
  #   dirWCRAN = dir(weird_windows_cran_loc),
  #   dir2Mac = dir(weird_mac_loc)
  #   # dir3 = dir(file.path("..", "..", "..", "packagedocs"))
  # )))
  # stop(paste(info, collapse = "\n"))

  pkg_obj <- as.package(pkg_path)
  rdl <- function(x) {
    rd_link(deparse(substitute(x)), pkg = pkg_obj)
  }

  expect_equivalent(
    rdl(devtools::build_vignettes(a = 2)),
    # "<code>devtools::<a href='http://www.inside-r.org/packages/cran/devtools/docs/build_vignettes'>build_vignettes</a>(a = 2)</code>" # nolint
    "<code>devtools::<a href='http://www.rdocumentation.org/packages/devtools/topics/build_vignettes'>build_vignettes</a>(a = 2)</code>" # nolint
  )

  expect_equivalent(
    rdl(graphics::plot(b = 2)),
    "<code>graphics::<a href='http://www.rdocumentation.org/packages/graphics/topics/plot'>plot</a>(b = 2)</code>" # nolint
  )
  expect_equivalent(
    rdl(nchar("5")),
    "<code><a href='http://www.rdocumentation.org/packages/base/topics/nchar'>nchar</a>(\"5\")</code>" # nolint
  )

  expect_equivalent(
    rdl(testpkg::fn_a(2)),
    "<code>testpkg::<a href='rd.html#fn_alias'>fn_a</a>(2)</code>" # nolint
  )

  expect_equivalent(
    rdl(fn_a(a = 2)),
    "<code><a href='rd.html#fn_alias'>fn_a</a>(a = 2)</code>" # nolint
  )

  expect_equivalent(
    rdl(fn_a(e = 2, fight = devtools::install())),
    "<code><a href='rd.html#fn_alias'>fn_a</a>(e = 2, fight = devtools::install())</code>" # nolint
  )

  expect_equivalent(
    rdl(keyword),
    "<code><a href='rd.html#keyword_alias'>keyword</a></code>"
  )

  expect_equivalent(
    rdl(devtools::build_vignettes),
    "<code>devtools::<a href='http://www.rdocumentation.org/packages/devtools/topics/build_vignettes'>build_vignettes</a></code>" # nolint
  )

})
