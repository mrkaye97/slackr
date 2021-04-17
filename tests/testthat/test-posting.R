test_that("slackr_bot posts", {
  skip_on_cran()

  res <- slackr_bot("testing slackr_bot")
  expect_equal(res$status_code, 200)
})

test_that("slackr posts", {
  skip_on_cran()

  res <- slackr("Testing")
  expect_true(res$ok)

  res <- slackr(head(iris))
  expect_true(res$ok)

  res <- slackr(
    summary(lm(Petal.Width ~ Sepal.Width, data = iris))
  )
  expect_true(res$ok)
})

test_that("ggslackr posts", {
  skip_on_cran()

  res <- ggslackr(
    ggplot(data = iris, aes(x = Petal.Width, y = Petal.Length, color = Species)) +
      geom_point()
  )
  expect_true(res$ok)
})

test_that("slackr_msg posts", {
  skip_on_cran()

  res <- slackr_msg("Testing")
  expect_true(res$ok)
})

test_that("text_slackr posts", {
  skip_on_cran()

  expect_warning(text_slackr("Testing"))
  expect_true(suppressWarnings(text_slackr("Testing"))$ok)
})

test_that("slackr_delete works", {
  skip_on_cran()

  slackr_msg("Testing deletion")
  res <- slackr_delete(1)
  expect_true(res[[1]]$ok)
})

test_that("slackr_upload posts", {
  skip_on_cran()

  x <- 1:10
  tf <- tempfile(fileext = ".Rdata")
  save(x, file = tf)
  res <- slackr_upload(tf, channels = "#test")
  unlink(tf)

  expect_equal(content(res)$ok, TRUE)
})

test_that("slackr can post to other channels", {
  skip_on_cran()

  res <- slackr("testing foreign channel post", channel = "#test2")
  expect_true(res$ok)
})


test_that("slackr_csv posts", {
  skip_on_cran()

  res <- slackr_csv(iris)
  expect_true(content(res)$ok)
})

test_that("slackr_save works", {
  skip_on_cran()

  res <- slackr_save(iris)
  expect_equal(res$ok, TRUE)

  ## making sure saving works from inside of a function
  f <- function() {
    x <- 1:2
    slackr_save(x)
  }

  res <- f()
  expect_equal(res$ok, TRUE)
})

test_that("ggslackr works from in a function", {
  skip_on_cran()

  f <- function() {
    plt <- ggplot2::ggplot(iris, ggplot2::aes(Sepal.Length, Sepal.Width)) +
      ggplot2::geom_point()

    ggslackr(plt)
  }


  res <- f()
  expect_equal(res$ok, TRUE)
})

