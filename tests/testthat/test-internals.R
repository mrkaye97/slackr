test_that("warn_for_args works as anticipated", {
  skip_on_cran()

  expect_error(
    warn_for_args(),
    "You must supply a token"
  )

  expect_error(
    warn_for_args(token = NA_character_),
    "You must supply a token"
  )

  expect_error(
    warn_for_args(token = NULL),
    "You must supply a token"
  )

  ## No error or return if nothing goes wrong
  expect_invisible(warn_for_args("xoxp-1234"))

  expect_warning(
    warn_for_args(token = "xoxp-1234", channel = "foo")
  )
})
