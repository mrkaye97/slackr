test_that("slackr_history correctly retrieves post", {

  post <- slackr("History test")

  history <- slackr_history(
    message_count = 1
  )

  expect_true(as.numeric(history$ts) - as.numeric(post$ts) < 1000)
  expect_identical(history$subtype, "bot_message")
})

test_that("slackr_history works when posted_from and posted_to are specified", {
  post <- slackr_msg("History posted_from posted_to test")

  history <- slackr_history(
    message_count = 1,
    posted_from_time = post$ts,
    posted_to_time = post$ts
  )

  expect_identical(post$message$text, history$text)
  expect_identical(post$message$subtype, history$subtype)
  expect_identical(post$message$ts, history$ts)
  expect_identical(post$message$bot_id, history$bot_id)
  expect_identical(post$message$app_id, history$app_id)
})

test_that("slackr_history works when posted_from and posted_to are specified for multiple posts", {
  post1 <- slackr_msg("History test post 1.")

  Sys.sleep(1)

  post2 <- slackr_msg("History test post 2.")
  post3 <- slackr_csv(iris, initial_comment = "History test post 3.")
  post4 <- slackr_msg("History test post 4.")

  all_history <- slackr_history(
    message_count = 1000,
    posted_from_time = post1$ts,
    posted_to_time = post4$ts
  )

  expect_gte(nrow(all_history), 4)
  expect_gte(length(Filter(function(.x) !is.null(.x), all_history$files)), 1)
  expect_equal(min(all_history$ts), post1$ts)
  expect_equal(max(all_history$ts), post4$ts)

  all_history <- slackr_history(
    message_count = 3,
    posted_from_time = post1$ts,
    posted_to_time = post2$ts
  )

  expect_identical(post$message$text, history$text)
  expect_identical(post$message$subtype, history$subtype)
  expect_identical(post$message$ts, history$ts)
  expect_identical(post$message$bot_id, history$bot_id)
  expect_identical(post$message$app_id, history$app_id)
})

test_that("Specifycing post times in slackr_history correctly limits time window", {
  post1 <- slackr_msg("History test post 1.")

  Sys.sleep(1)

  post2 <- slackr_msg("History test post 2.")

  Sys.sleep(1)
  post3 <- slackr_msg("History test post 4.")

  all_history <- slackr_history(
    message_count = 1000,
    posted_from_time = post1$ts,
    posted_to_time = post2$ts
  )

  expect_equal(min(all_history$ts), post1$ts)
  expect_equal(max(all_history$ts), post2$ts)
  expect_lt(as.numeric(max(all_history$ts)), as.numeric(post3$ts))
})

