if(Sys.getenv("SLACK_API_TOKEN") == ""){
  api_token <- yaml::read_yaml(file.path("inst", "exdata", "slackr_creds.yml"))$slackr$api_token
  Sys.setenv("SLACK_API_TOKEN" = api_token)
} else {
  api_token <- Sys.getenv("SLACK_API_TOKEN")
}
#NB: relies on Sys.getenv("SLACK_API_TOKEN")

test_that("slackr_bot: webhook fails/works appropriately", {

  expect_error(slackr_bot(txt = "testing 1,2,3",
                            channel = "#publichanneltest",
                            incoming_webhook_url = "BAD HOOK"
                            ),
                 regexp = "Couldn't resolve host 'BAD HOOK'")
  Sys.sleep(1)
  expect_silent(slackr_bot(txt = "testing 1,2,3",
                            channel = "#publicchanneltest",
                            incoming_webhook_url = "https://hooks.slack.com/services/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")
                )
  Sys.sleep(1)


  expect_error(slackr_bot(txt = "testing 1,2,3"), regexp = "No incoming webhook URL specified. Did you forget to call slackr_setup()?")

})

