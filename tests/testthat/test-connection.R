test_that("slackr_setup() connects", {
  expect_equal(
    slackr_setup(
      channel = "#test",
      bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")),
    "Successfully connected to Slack"
  )

  expect_true(
    grepl("^xox.-", Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"))
  )
  expect_equal(
    Sys.getenv("SLACK_CHANNEL"),
    '#test'
  )

  slackr_createcache()

  expect_true(
    grepl(
      "\\.Rcache$",
      R.cache::findCache(key = list('channel_cache')))
  )
  channel_cache <- loadCache(key = list('channel_cache'))
  expect_true(nrow(channel_cache) > 0)
})
