
library(yaml)
library(testthat)
library(slackr)
# Some useful references about testing Slack apps/bots
# Mocking: https://github.com/Skellington-Closet/slack-mock
# Slack's test api:  https://api.slack.com/methods/api.test
# Best practices for API packages: https://discuss.ropensci.org/t/best-practices-for-testing-api-packages/460/7

creds <- yaml::yaml.load_file(input = "~/src/slackr_creds.yml")

context("basic functioning")

test_that("Webhook fails/works appropriately", {
  slackr_setup(channel = "#publicchanneltest",
               incoming_webhook_url = creds$slack_bot$invalid$webhook,
               username = "slackr_bot")

  expect_warning(slackr_bot(txt = "testing 1,2,3"))

  Sys.sleep(1)
  slackr_setup(channel = "#publicchanneltest",
               incoming_webhook_url = creds$slack_bot$valid$webhook,
               username = "slackr_bot")

  expect_error(slackr_bot(txt = "testing 1,2,3"), NA)

})


test_that("Valid api tokens work", {
  # On github, should be done with Env variable.

  slackr_setup(channel = "#publicchanneltest",
               api_token = creds$slack_bot$valid$api_token,
               username = "slackr_bot",
               icon_emoji = "thumbsup")

  # Does not respect username, icon, etc.
  expect_error(
    slackr::slackr_msg(txt = paste("testing ", Sys.time())),
               regexp = NA)
  Sys.sleep(1)
  expect_error(res <- slackr::slackr_msg(txt = "testing 1,2,3",
                            channel = "@dp.egan"),
               regexp = NA)
  Sys.sleep(1)
  expect_error(text_slackr(text = "testing text_slackr",
                             icon_emoji = "robot",
                             username = "cashhubbot",
                             channel = "@dp.egan"),
               regexp = NA)
  Sys.sleep(1)
  expect_error(slackr_upload(filename = "~/Desktop/529.png",
                        initial_comment = "Testing",
                        channel = "@foobarmaxo"),
               regexp = "Could not find ")

})
