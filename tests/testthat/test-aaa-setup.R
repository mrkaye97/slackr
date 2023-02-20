test_that("Connect + Auth", {
  if (Sys.getenv("ENVIRONMENT") == "production") {
    slackr_setup(
      channel = Sys.getenv("SLACK_CHANNEL"),
      username = Sys.getenv("SLACK_USERNAME"),
      icon_emoji = Sys.getenv("SLACK_ICON_EMOJI"),
      incoming_webhook_url = Sys.getenv("SLACK_INCOMING_WEBHOOK_URL"),
      token = Sys.getenv("SLACK_TOKEN")
    )
  } else {
    slackr_setup(
      config_file = "~/.slackr_config"
    )
  }

  expect_true(auth_test()$ok)
})
