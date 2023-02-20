test_that("slackr_bot posts", {
  skip_on_cran()

  res <- slackr_bot("testing slackr_bot")$content %>%
    rawToChar()
  expect_equal(res, "ok")
})

test_that("slackr_bot posts from inside a function", {
  skip_on_cran()

  x <- function() {
    res <- slackr_bot("testing slackr_bot")$content %>%
      rawToChar()

    res
  }

  expect_equal(x(), "ok")
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

test_that("slackr posts from inside a function", {
  skip_on_cran()

  x <- function() {
    res <- slackr("testing slackr_bot")
    res
  }

  expect_true(x()$ok)
})

test_that("ggslackr posts png by default", {
  skip_on_cran()

  res <- ggslackr(
    ggplot2::ggplot(data = iris, ggplot2::aes(x = Petal.Width, y = Petal.Length, color = Species)) +
      ggplot2::geom_point(),
    units = "in"
  )
  expect_true(res$ok)
})

test_that("ggslackr posts pdfs", {
  skip_on_cran()

  res <- ggslackr(
    ggplot2::ggplot(data = iris, ggplot2::aes(x = Petal.Width, y = Petal.Length, color = Species)) +
      ggplot2::geom_point(),
    device = "pdf",
    units = "in"
  )

  expect_true(res$ok)
})

test_that("ggslackr posts tiffs", {
  skip_on_cran()

  res <- ggslackr(
    ggplot2::ggplot(data = iris, ggplot2::aes(x = Petal.Width, y = Petal.Length, color = Species)) +
      ggplot2::geom_point(),
    device = "tiff",
    units = "in"
  )

  expect_true(res$ok)
})

test_that("ggslackr posts svgs", {
  skip_on_cran()
  skip_on_ci()

  res <- ggslackr(
    ggplot2::ggplot(data = iris, ggplot2::aes(x = Petal.Width, y = Petal.Length, color = Species)) +
      ggplot2::geom_point(),
    device = "svg",
    units = "in"
  )

  expect_true(res$ok)
})

test_that("slackr_msg posts", {
  skip_on_cran()

  res <- slackr_msg("Testing")
  expect_true(res$ok)
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

  expect_true(res$ok)
})

test_that("slackr can post to other channels", {
  skip_on_cran()

  res <- slackr("testing foreign channel post", channel = "#test2")
  expect_true(res$ok)
})


test_that("slackr_csv posts", {
  skip_on_cran()

  res <- slackr_csv(iris)
  expect_true(res$ok)
})

test_that("slackr_save works", {
  skip_on_cran()

  res <- slackr_save(iris)
  expect_true(res$ok)

  ## making sure saving works from inside of a function
  f <- function() {
    x <- 1:2
    slackr_save(x)
  }

  res <- f()
  expect_true(res$ok)
})

test_that("ggslackr works from in a function", {
  skip_on_cran()

  f <- function() {
    plt <- ggplot2::ggplot(iris, ggplot2::aes(Sepal.Length, Sepal.Width)) +
      ggplot2::geom_point()

    ggslackr(plt, units = "in")
  }

  res <- f()
  expect_true(res$ok)
})

test_that("thread ts correctly posts", {
  skip_on_cran()

  post <- slackr_msg("Thread")

  reply_1 <- slackr_msg("Reply", thread_ts = post$ts)

  expect_equal(post$ts, reply_1$message$thread_ts)
})
