library(testthat)
library(yaml)
library(slackr)
library(assertthat)

#' On travis, this is specified as an env var.
#' Can't commit it to github, so if you need the local creds, ask dan egan

if(Sys.getenv("SLACK_API_TOKEN") == ""){
  api_token <- yaml::read_yaml(file.path("inst", "exdata", "slackr_creds.yml"))$slackr$api_token
  Sys.setenv("SLACK_API_TOKEN" = api_token)
} else {
  api_token <- Sys.getenv("SLACK_API_TOKEN")
}


test_check("slackr")

# Some useful references about testing Slack apps/bots
# Mocking: https://github.com/Skellington-Closet/slack-mock
# Slack's test api:  https://api.slack.com/methods/api.test
# Best practices for API packages: https://discuss.ropensci.org/t/best-practices-for-testing-api-packages/460/7
