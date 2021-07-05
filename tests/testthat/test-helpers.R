test_that("Auth works", {
  skip_on_cran()

  auth <- auth_test()

  expect_true(
    auth$ok
  )
})

test_that("chrtrans works", {
  skip_on_cran()

  channel <- slackr_chtrans("#test")

  expect_equal(
    channel,
    "C01K5VCPLGZ"
  )
})

test_that("Channels works", {
  skip_on_cran()

  channels <- slackr_channels()

  expect_equal(
    ncol(channels),
    26
  )

  expect_gte(
    nrow(channels),
    6
  )

  expect_true(
    "test" %in% channels$name
  )
})

test_that("Users works", {
  skip_on_cran()

  users <- slackr_users()

  expect_true(
    "mrkaye97" %in% users$name
  )
})
