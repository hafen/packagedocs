


context("rd_link")


test_that("links", {

  rdl <- function(x) rd_link(deparse(substitute(x)), pkg = "../../")

  expect_equivalent(
    rdl(devtools::build_vignettes(a = 2)),
    "<code>devtools::<a href='http://www.inside-r.org/packages/cran/devtools/docs/build_vignettes'>build_vignettes</a>(a = 2)</code>" # nolint
  )

  expect_equivalent(
    rdl(graphics::plot(b = 2)),
    "<code>graphics::<a href='http://www.inside-r.org/r-doc/graphics/plot'>plot</a>(b = 2)</code>" # nolint
  )
  expect_equivalent(
    rdl(plot(b = 21)),
    "<code><a href='http://www.inside-r.org/r-doc/graphics/plot'>plot</a>(b = 21)</code>" # nolint
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
    "<code>devtools::<a href='http://www.inside-r.org/packages/cran/devtools/docs/build_vignettes'>build_vignettes</a></code>" # nolint
  )

})
