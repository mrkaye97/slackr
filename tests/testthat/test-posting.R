# this one is bombing on devtools::check because it thinks there's no webhook set up (there is).
# it also weirdly works fine when I click "Run Tests" in RStudio.
# test_that("slackr_bot posts", {
#   slackr_bot_test <- slackr_bot('testing slackr_bot', incoming_webhook_url = Sys.getenv("SLACK_INCOMING_URL_PREFIX"))
#   expect_equal(rawToChar(slackr_bot_test$content), 'ok')
# })

test_that("slackr posts", {
  res <- slackr('Testing')
  expect_true(res$ok)

  res <- slackr(head(iris))
  expect_true(res$ok)

  res <- slackr(
    summary(lm(Petal.Width ~ Sepal.Width, data = iris))
  )
  expect_true(res$ok)
})

test_that("ggslackr posts", {
  res <- ggslackr(
    ggplot(data = iris, aes(x = Petal.Width, y = Petal.Length, color = Species)) +
      geom_point()
  )
  expect_true(res$ok)
})

test_that("slackr_msg posts", {
  res <- slackr_msg('Testing')
  expect_true(res$ok)
})

test_that("text_slackr posts", {
  res <- text_slackr('Testing')
  expect_true(res$ok)
})

test_that("slackr_delete works", {
  slackr_msg('Testing deletion')
  res <- slackr_delete(1)
  expect_true(res[[1]]$ok)
})

test_that("slackr_upload posts", {
  x <- 1:10
  tf <- tempfile(fileext = ".Rdata")
  save(x, file = tf)
  res <- slackr_upload(tf, channels = '#test')
  unlink(tf)

  expect_equal(content(res)$ok, TRUE)
})

test_that("slackr can post to other channels", {
  res <- slackr('testing foreign channel post', channel = '#test2')
  expect_true(res$ok)
})


