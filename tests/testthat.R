library(testthat)
library(slackr)

if (Sys.getenv('ENVIRONMENT') == 'production') {
  slackr_setup(
    channel = Sys.getenv("SLACK_CHANNEL"),
    username = Sys.getenv("SLACK_USERNAME"),
    icon_emoji = Sys.getenv("SLACK_ICON_EMOJI"),
    incoming_webhook_url = Sys.getenv("SLACK_INCOMING_URL_PREFIX"),
    bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")
  )
} else {
  slackr_setup(
    config_file = '~/.slackr_config'
  )
}

test_check("slackr")
