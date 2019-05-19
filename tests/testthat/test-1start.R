source("helpers/helper_loadCredentials.R")

# Some useful references about testing Slack apps/bots
# Mocking: https://github.com/Skellington-Closet/slack-mock
# Slack's test api:  https://api.slack.com/methods/api.test
# Best practices for API packages: https://discuss.ropensci.org/t/best-practices-for-testing-api-packages/460/7
library(yaml)
creds <- loadCredentials(service.name = "slackr_test_api", yaml.path = "~/src/slackr/slackr_creds.yaml")

Sys.setenv("SLACK_API_TOKEN" = creds$api_token)
