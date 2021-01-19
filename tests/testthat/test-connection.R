test_that("slackr_setup() connects", {
  slackr_setup(channel = "#test",
               bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"),
               cacheChannels = F)
  expect_equal(substr(Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"), 1, 4), 'xoxb')
  expect_equal(Sys.getenv("SLACK_CHANNEL"), '#test')
  expect_equal(Sys.getenv("SLACK_USERNAME"), 'slackr')
  expect_equal(slackr_setup(channel = "#test",
                            bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"),
                            cacheChannels = F),
                 "Successfully connected to Slack")
})

test_that("channels are cached", {
  slackr_setup(channel = "#test",
               bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"),
               cacheChannels = T)

  channel_cache <- read.csv('.channel_cache')
  expect_gt(nrow(channel_cache), 0)
})