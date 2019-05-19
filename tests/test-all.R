library(testthat)
library(yaml)
library(slackr)

slackr_setup(config_file = system.file(file.path("exdata", "slackr_config.dcf"), package = "slackr"))

test_check("slackr")

# Some useful references about testing Slack apps/bots
# Mocking: https://github.com/Skellington-Closet/slack-mock
# Slack's test api:  https://api.slack.com/methods/api.test
# Best practices for API packages: https://discuss.ropensci.org/t/best-practices-for-testing-api-packages/460/7
