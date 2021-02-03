test_that("slackr_setup() connects", {
  skip_on_cran()

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
})
