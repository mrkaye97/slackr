test_that("slackrChannelsUsersIms deprecated", {
  skip_on_cran()

  expect_warning(slackrChannels(), regexp = "'slackrChannels' is deprecated")
  expect_warning(slackrIms(), regexp = "'slackrIms' is deprecated")
  expect_warning(slackrUsers(), regexp = "'slackrUsers' is deprecated")
})

test_that("slackrChTrans deprecated", {
  skip_on_cran()

  expect_warning(slackrChTrans(channels = "#test"), regexp = "'slackrChTrans' is deprecated")
  expect_warning(slackrChtrans(channels = "#test"), regexp = "'slackrChtrans' is deprecated")
})

test_that("slackrMsg deprecated", {
  skip_on_cran()

  expect_warning(slackrMsg("deprecation test"), regexp = "'slackrMsg' is deprecated")
})

test_that("text_slackr deprecated", {
  skip_on_cran()

  expect_warning(text_slackr("deprecation test"), regexp = "'text_slackr' is deprecated")
  expect_warning(textSlackr("deprecation test"), regexp = "'text_slackr' is deprecated") %>%
    expect_warning(regexp = "'textSlackr' is deprecated")
})

test_that("save_slackr deprecated", {
  skip_on_cran()

  ## this errors out but I can't figure out why
  ## I think it has something to do with save(..., envir = parent.frame())
  ## but it seems to work fine in slackr_save()
  x <- 1:2
  expect_error(save_slackr(x), regexp = "object") %>%
    expect_warning(regexp = "deprecated")
})

test_that("slackr_setup deprecated args", {
  skip_on_cran()

  expect_warning(
    slackr_setup(
      channel = "#test",
      bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"),
      incoming_webhook_url = Sys.getenv("SLACK_INCOMING_URL_PREFIX"),
      cacheChannels = TRUE
    ),
    regexp = "cacheChannels parameter is deprecated"
  )
})
