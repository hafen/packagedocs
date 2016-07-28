

context("to_html")

test_that("else", {
  expect_equivalent(to_html("asdf"), "asdf")
  expect_equivalent(to_html.character("asdf"), "asdf")
})
