test_that("slackr_history correctly retrieves post", {
  skip_on_cran()

  lapply(
    c(TRUE, FALSE),
    function(paginate) {
      post <- slackr("History test")

      history <- slackr_history(
        message_count = 1,
        posted_from_time = post$ts,
        posted_to_time = post$ts,
        paginate = paginate
      )

      expect_true(as.numeric(history$ts) - as.numeric(post$ts) < 1000)
      expect_identical(history$subtype, "bot_message")
    }
  )
})

test_that("slackr_history works when posted_from and posted_to are specified", {
  skip_on_cran()

  lapply(
    c(TRUE, FALSE),
    function(paginate) {
      post <- slackr_msg("History posted_from posted_to test")

      history <- slackr_history(
        message_count = 1,
        posted_from_time = post$ts,
        posted_to_time = post$ts,
        paginate = paginate
      )

      expect_identical(post$message$text, history$text)
      expect_identical(post$message$subtype, history$subtype)
      expect_identical(post$message$ts, history$ts)
      expect_identical(post$message$bot_id, history$bot_id)
      expect_identical(post$message$app_id, history$app_id)
    }
  )
})

test_that("slackr_history works with duration specified", {
  skip_on_ci()
  skip_on_cran()

  post1 <- slackr_msg("History test post 1.")

  Sys.sleep(5)

  post2 <- slackr_msg("History test post 2.")

  Sys.sleep(1.50)
  to_ts <- as.numeric(Sys.time())

  ## Check the past seven seconds
  dur_s <- 7
  dur_ms <- dur_s * 1000
  dur_hours <- dur_s / 3600

  history <- slackr_history(
    message_count = 1000,
    posted_to_time = to_ts,
    duration = dur_hours
  )

  expect_gte(nrow(history), 2)
  expect_gte(min(as.numeric(history$ts)), to_ts - dur_ms)

  history_limited <- slackr_history(
    message_count = 1000,
    posted_to_time = to_ts,
    duration = dur_hours / 2
  )

  expect_gte(as.numeric(post2$ts), max(as.numeric(history_limited$ts)))
  expect_gte(nrow(history_limited), 1)
})

test_that("slackr_history works when posted_from and posted_to are specified for multiple posts", {
  skip_on_cran()

  lapply(
    c(TRUE, FALSE),
    function(paginate) {
      post1 <- slackr_msg("History test post 1.")

      Sys.sleep(1)

      post2 <- slackr_msg("History test post 2.")
      post3 <- slackr_csv(iris, initial_comment = "History test post 3.")
      post4 <- slackr_msg("History test post 4.")

      all_history <- slackr_history(
        message_count = 1000,
        posted_from_time = post1$ts,
        posted_to_time = post4$ts,
        paginate = paginate
      )

      expect_gte(nrow(all_history), 4)
      expect_gte(length(Filter(function(.x) !is.null(.x), all_history$files)), 1)
      expect_equal(min(all_history$ts), post1$ts)
      expect_equal(max(all_history$ts), post4$ts)

      all_history <- slackr_history(
        message_count = 1000,
        posted_from_time = post1$ts,
        posted_to_time = post2$ts,
        paginate = paginate
      )

      expect_gte(nrow(all_history), 2)
      expect_lte(min(as.numeric(all_history$ts)), as.numeric(post1$ts))
      expect_gte(max(as.numeric(all_history$ts)), as.numeric(post2$ts))
    }
  )
})

test_that("Specifying post times in slackr_history correctly limits time window", {
  skip_on_cran()

  lapply(
    c(TRUE, FALSE),
    function(paginate) {
      post1 <- slackr_msg("History test post 1.")

      Sys.sleep(1)

      post2 <- slackr_msg("History test post 2.")

      Sys.sleep(1)
      post3 <- slackr_msg("History test post 4.")

      all_history <- slackr_history(
        message_count = 1000,
        posted_from_time = post1$ts,
        posted_to_time = post2$ts,
        paginate = paginate
      )

      expect_lte(min(as.numeric(all_history$ts)), as.numeric(post1$ts))
      expect_gte(max(as.numeric(all_history$ts)), as.numeric(post2$ts))
      expect_lt(as.numeric(max(all_history$ts)), as.numeric(post3$ts))
    }
  )
})

test_that("Expect warning for too many params", {
  skip_on_cran()

  from_time <- slackr_msg("History warning test start")$ts
  Sys.sleep(1)
  slackr_msg("History warning test")
  Sys.sleep(1)
  to_time <- slackr_msg("History warning test end")$ts

  expect_silent(
    slackr_history(
      posted_to_time = to_time,
      duration = 2 * (as.numeric(to_time) - as.numeric(from_time)) / (60 * 60)
    )
  )

  expect_warning(
    slackr_history(
      posted_from_time = from_time,
      posted_to_time = to_time,
      duration = 2 * (as.numeric(to_time) - as.numeric(from_time)) / (60 * 60)
    ),
    "You specified all three of"
  )
})

test_that("Error if trying to paginate with no start time", {
  skip_on_cran()

  expect_error(
    slackr_history(
      paginate = TRUE
    ),
    "To use pagination with `slackr_history`, you must specify a value for `posted_from_time`"
  )
})
