


context("rd_link")

test_that("links", {

  wd <- getwd()
  if (grepl("tests_i386|tests_x64", wd)) {
    # done to make sure the pkg_path points to the pkg source
    # only happens on build_win()
    pkg_path <- pkg_path <- file.path("..", "..", "..", "packagedocs")
  } else {
    pkg_path <- "."
  }

  # info <- capture.output(dput(list(
  #   pwd = getwd(),
  #   dir3 = dir(file.path("..", "..", "..", "packagedocs"))
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
    # "<code>graphics::<a href='http://www.inside-r.org/r-doc/graphics/plot'>plot</a>(b = 2)</code>" # nolint
    "<code>graphics::<a href='http://www.rdocumentation.org/packages/graphics/topics/plot'>plot</a>(b = 2)</code>" # nolint
  )
  expect_equivalent(
    rdl(plot(b = 21)),
    # "<code><a href='http://www.inside-r.org/r-doc/graphics/plot'>plot</a>(b = 21)</code>" # nolint
    "<code><a href='http://www.rdocumentation.org/packages/graphics/topics/plot'>plot</a>(b = 21)</code>" # nolint
  )

  expect_equivalent(
    rdl(packagedocs::build_vignettes(c = 2)),
    "<code>packagedocs::<a href='rd.html#build_vignettes_alias'>build_vignettes</a>(c = 2)</code>" # nolint
  )

  expect_equivalent(
    rdl(build_vignettes(d = 2)),
    "<code><a href='rd.html#build_vignettes_alias'>build_vignettes</a>(d = 2)</code>" # nolint
  )

  expect_equivalent(
    rdl(build_vignettes(e = 2, fight = devtools::install())),
    "<code><a href='rd.html#build_vignettes_alias'>build_vignettes</a>(e = 2, fight = devtools::install())</code>" # nolint
  )

  expect_equivalent(
    rdl(build_vignettes),
    "<code><a href='rd.html#build_vignettes_alias'>build_vignettes</a></code>"
  )

  expect_equivalent(
    rdl(devtools::build_vignettes),
    # "<code>devtools::<a href='http://www.inside-r.org/packages/cran/devtools/docs/build_vignettes'>build_vignettes</a></code>" # nolint
    "<code>devtools::<a href='http://www.rdocumentation.org/packages/devtools/topics/build_vignettes'>build_vignettes</a></code>" # nolint
  )

})
