set_up_test_env <- function(..., env = Sys.getenv("ENVIRONMENT")) {
  if (env == "production") {
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
}

with_slack_config <- function(code, env = Sys.getenv("ENVIRONMENT")) {
  impl <- withr::with_(
    set = set_up_test_env,
    reset = set_up_test_env
  )

  impl(
    code = code,
    env = env
  )
}
