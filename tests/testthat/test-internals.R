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
    28
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

test_that("with_retry correctly retries requests", {
  skip_on_cran()

  i <- 1

  mock <- function() {
    if (i > 1) {
      httr:::response(
        headers = list(`retry-after` = 2),
        status_code = 200,
        ok = TRUE
      )
    } else {
      i <<- i + 1
      httr:::response(
        headers = list(`retry-after` = 2),
        status_code = 429
      )
    }
  }

  expect_message(with_retry(mock), "Pausing for 2 seconds due to Slack API rate limit")

  out <- with_retry(mock)

  expect_true(out$ok)
  expect_equal(out$status_code, 200)
})
