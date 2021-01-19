# this one is bombing on devtools::check because it thinks there's no webhook set up (there is).
# it also weirdly works fine when I click "Run Tests" in RStudio.
# test_that("slackr_bot posts", {
#   slackr_bot_test <- slackr_bot('testing slackr_bot', incoming_webhook_url = Sys.getenv("SLACK_INCOMING_URL_PREFIX"))
#   expect_equal(rawToChar(slackr_bot_test$content), 'ok')
# })

test_that("slackr posts", {
  slackr_msg_test <- slackr('Testing')
  expect_equal(content(slackr_msg_test)$ok, TRUE)

  slackr_tbl_test <- slackr(head(iris))
  expect_equal(content(slackr_tbl_test)$ok, TRUE)

  slackr_lm_test <- slackr(
    summary(lm(Petal.Width ~ Sepal.Width, data = iris))
  )
  expect_equal(content(slackr_lm_test)$ok, TRUE)
})

test_that("ggslackr posts", {
  slackr_gg_test <- ggslackr(
    ggplot(data = iris, aes(x = Petal.Width, y = Petal.Length, color = Species)) +
      geom_point()
  )
  expect_equal(content(slackr_gg_test)$ok, TRUE)
})

test_that("slackr_msg posts", {
  slackr_msg_test <- slackr_msg('Testing')
  expect_equal(content(slackr_msg_test)$ok, TRUE)
})

test_that("text_slackr posts", {
  text_slackr_test <- text_slackr('Testing')
  expect_equal(content(text_slackr_test)$ok, TRUE)
})

test_that("slackr_delete works", {
  slackr_msg('Testing deletion')
  slackr_delete_test <- slackr_delete(1)
  expect_equal(content(slackr_delete_test[[1]])$ok, TRUE)
})

test_that("slackr_upload posts", {
  save(x, file = 'slackr_upload_test.Rdata')
  slackr_upload_test <- slackr_upload('slackr_upload_test.Rdata', channels = '#test')
  unlink('slackr_upload_test.Rdata')

  expect_equal(content(slackr_upload_test)$ok, TRUE)
})

# this one is bombing on devtools::check() I think because the plot isn't being rendered
# test_that("dev_slackr posts", {
#   plot(iris$Sepal.Length, iris$Sepal.Width)
#   dev_slackr_test <- dev_slackr()
#   expect_equal(content(dev_slackr_test)$ok, TRUE)
# })

test_that("save_slackr posts", {
  save_slackr_test <- save_slackr(x, channels = '#test', file = 'save_slackr_test.Rdata')
  expect_equal(content(save_slackr_test)$ok, TRUE)
})

test_that("slackr can post to other channels", {
  slackr_foreign_channel_test <- slackr('testing foreign channel post', channel = '@mrkaye97')
  expect_equal(content(slackr_foreign_channel_test)$ok, TRUE)
})


