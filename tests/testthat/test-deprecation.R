test_that("slackrChannelsUsersIms deprecated", {
  skip_on_cran()

  expect_warning(slackrChannels(), regexp = "'slackrChannels' is deprecated")
  expect_warning(slackrIms(), regexp = "'slackrIms' is deprecated")
  expect_warning(slackrUsers(), regexp = "'slackrUsers' is deprecated")
})

test_that("slackrChTrans deprecated", {
  skip_on_cran()

  expect_warning(slackrChTrans(channels = '#test'), regexp = "'slackrChTrans' is deprecated")
  expect_warning(slackrChtrans(channels = '#test'), regexp = "'slackrChtrans' is deprecated")
})

test_that("slackrMsg deprecated", {
  skip_on_cran()

  expect_warning(slackrMsg('deprecation test'), regexp = "'slackrMsg' is deprecated")
})

test_that("text_slackr deprecated", {
  skip_on_cran()

  expect_warning(text_slackr('deprecation test'), regexp = "'text_slackr' is deprecated")
  expect_warning(textSlackr('deprecation test'), regexp = "'text_slackr' is deprecated") %>%
    expect_warning(regexp = "'textSlackr' is deprecated")
})
