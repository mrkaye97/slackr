api_token <- getAPIToken()
webhook <- getWebhook()

test_that("slackr_bot: webhook fails/works appropriately", {

  expect_error(slackr_bot(txt = "testing 1,2,3",
                            channel = "#publichanneltest",
                            incoming_webhook_url = "BAD HOOK"
                            ),
                 regexp = "resolve host")
  Sys.sleep(1)

  expect_silent(slackr_bot(txt = "testing 1,2,3",
                            channel = "#publicchanneltest",
                            incoming_webhook_url = webhook)
                )
  Sys.sleep(1)

  expect_error(slackr_bot(txt = "testing 1,2,3"), regexp = "No incoming webhook URL specified. Did you forget to call slackr_setup()?")

})

