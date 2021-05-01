test_that("Initial setup completes", {
  skip_on_cran()

  expect_equal(
    if (Sys.getenv("ENVIRONMENT") == "production") {
      slackr_setup(
        channel = Sys.getenv("SLACK_CHANNEL"),
        username = Sys.getenv("SLACK_USERNAME"),
        icon_emoji = Sys.getenv("SLACK_ICON_EMOJI"),
        incoming_webhook_url = Sys.getenv("SLACK_INCOMING_URL_PREFIX"),
        bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")
      )
    } else {
      slackr_setup(
        config_file = "~/.slackr_config"
      )
    },
    'Successfully connected to Slack'
  )
})

test_that("slackr_setup() connects", {
  skip_on_cran()

  expect_equal(
    slackr_setup(
      channel = "#test",
      bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"),
      incoming_webhook_url = Sys.getenv("SLACK_INCOMING_URL_PREFIX"),
      username = "slackr",
      icon_emoji = "robot_face"
    ),
    "Successfully connected to Slack"
  )

  expect_true(
    grepl("^xox.-", Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"))
  )

  expect_true(
    grepl("^https://hooks", Sys.getenv("SLACK_INCOMING_URL_PREFIX"))
  )

  expect_equal(
    Sys.getenv("SLACK_CHANNEL"),
    "#test"
  )
})

test_that("config file setup works", {
  skip_on_cran()

  tmp <- tempfile()
  write.dcf(
    list(
      bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"),
      channel = Sys.getenv("SLACK_CHANNEL"),
      username = Sys.getenv("SLACK_USERNAME"),
      incoming_webhook_url = Sys.getenv("SLACK_INCOMING_URL_PREFIX"),
      icon_emoji = Sys.getenv("SLACK_ICON_EMOJI")
    ),
    file = tmp
  )

  expect_equal(
    slackr_setup(config_file = tmp),
    "Successfully connected to Slack"
  )
})
