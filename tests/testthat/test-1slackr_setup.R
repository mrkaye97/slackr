if(Sys.getenv("SLACK_API_TOKEN") == ""){
  api_token <- yaml::read_yaml(file.path("inst", "exdata", "slackr_creds.yml"))$slackr$api_token
  Sys.setenv("SLACK_API_TOKEN" = api_token)
} else {
  api_token <- Sys.getenv("SLACK_API_TOKEN")
}

test_that("slackr_setup works ", {
  expect_silent(slackr_setup(channel = "#publicchanneltest",
               username = "slackr_bot",
               api_token = api_token ))
})
