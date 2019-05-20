context("slackr_msg")

if(Sys.getenv("SLACK_API_TOKEN") == ""){
  api_token <- yaml::read_yaml(file.path("inst", "exdata", "slackr_creds.yml"))$slackr$api_token
  Sys.setenv("SLACK_API_TOKEN" = api_token)
} else {
  api_token <- Sys.getenv("SLACK_API_TOKEN")
}


test_that("slackr_msg: failure when not setup yet", {
  # On github, should be done with Env variable.

  expect_warning(
    #NB: Bot must be invited to channel by user.
    slackr::slackr_msg(txt = paste("testing: ", Sys.time()),
                       channel = "#publicchanneltest"),
    regexp = "tibble")

})

slackr_setup(api_token = api_token)

test_that("slackr_msg: Post-setup api tokens work", {
  # Does not respect username, icon, etc.
  expect_silent(
    #NB: Bot must be invited to channel by user.
    slackr::slackr_msg(txt = paste("testing: ", Sys.time()), channel = "#publicchanneltest")
  )
  Sys.sleep(1)
  expect_silent(slackr::slackr_msg(txt = "testing direct posting",
                                   channel = "@dp.egan"))
  Sys.sleep(1)
  expect_silent(text_slackr(text = "testing: text_slackr",
                            icon_emoji = "robot",
                            username = "TestBot",
                            channel = "@dp.egan"))
  Sys.sleep(1)
  expect_error(slackr_upload(filename = "~/Desktop/529.png",
                             initial_comment = "Testing",
                             channel = "@foobarmaxo"),
               regexp = "not found")

})
