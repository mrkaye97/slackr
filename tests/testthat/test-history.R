test_that("slackr_history correctly retrieves post", {
  skip_on_cran()

  lapply(
    c(TRUE, FALSE),
    function(paginate) {
      post <- slackr("History test")

      history <- slackr_history(
        message_count = 1,
        posted_from_time = post$ts,
        posted_to_time = post$ts,
        paginate = paginate
      )

      expect_true(as.numeric(history$ts) - as.numeric(post$ts) < 1000)
      expect_identical(history$subtype, "bot_message")
    }
  )
})

