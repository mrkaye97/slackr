context("slackr_msg")

api_token <- getAPIToken()

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
  expect_silent(
    slackr_upload(filename = file.path(system.file(package = "slackr"), "exdata", "lorax.jpg"),
                             initial_comment = "Testing",
                             channel = "@dp.egan"))
  Sys.sleep(1)
  expect_error(slackr_upload(filename = file.path(system.file(package = "slackr"), "exdata", "not_real_file.png"),
                             initial_comment = "Testing",
                             channel = "@foobarmaxo"),
               regexp = "not found")
  expect_error(slackr_upload(filename = file.path(system.file(package = "slackr"), "exdata", "lorax.jpg"),
                             initial_comment = "Testing",
                             channel = "@foobarmaxo"),
               regexp = "Close matches:  None.")
})
