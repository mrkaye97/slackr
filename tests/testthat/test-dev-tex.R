test_that("slackr_dev posts", {
  skip_on_cran()
  skip_on_ci()

  hist(rnorm(100))

  post <- slackr_dev()

  expect_true(post$ok)
  expect_equal(post$file$filetype, "png")
})

test_that("slackr_tex posts", {
  skip_on_cran()

  ## No path specified
  post <- slackr_tex("$$e^{i \\pi} + 1 = 0$$")

  expect_true(post$ok)
  expect_equal(post$file$filetype, "png")
})

test_that("slackr_tex posts", {
  skip_on_cran()

  ## With path specified
  d <- tempdir()
  post <- slackr_tex("$$e^{i \\pi} + 1 = 0$$", path = d)

  unlink(d, recursive = TRUE)
  expect_true(post$ok)
  expect_equal(post$file$filetype, "png")
})
