test_that("onexit usage works as expected", {
  skip_on_cran()

  slack_lm <- register_onexit(lm, "testing onexit")

  formula <- Sepal.Length ~ Sepal.Width
  mod <- slack_lm(formula, data = iris)

  expect_identical(
    mod$coefficients,
    lm(formula, data = iris)$coefficients
  )
})
