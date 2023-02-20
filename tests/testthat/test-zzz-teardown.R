test_that("config file write works", {
  skip_on_cran()
  skip_on_ci()

  tmp <- tempfile()
  create_config_file(tmp)

  slackr_teardown()

  env_vars <- c(
    "SLACK_TOKEN",
    "SLACK_CACHE_DIR",
    "SLACK_CHANNEL",
    "SLACK_ICON_EMOJI",
    "SLACK_INCOMING_WEBHOOK_URL",
    "SLACK_USERNAME"
  )

  lapply(
    env_vars,
    function(x) expect_equal(Sys.getenv(x), "")
  )

  expect_equal(
    slackr_setup(config_file = tmp),
    "Successfully connected to Slack"
  )
})


test_that("teardown works", {
  skip_on_cran()
  slackr_teardown()

  env_vars <- c(
    "SLACK_TOKEN",
    "SLACK_CACHE_DIR",
    "SLACK_CHANNEL",
    "SLACK_ICON_EMOJI",
    "SLACK_INCOMING_WEBHOOK_URL",
    "SLACK_USERNAME"
  )

  lapply(
    env_vars,
    function(x) expect_equal(Sys.getenv(x), "")
  )
})

test_that("Bad token throws error", {
  skip_on_cran()

  expect_error(
    slackr_setup(token = "This is a fake token"),
    "Could not connect to Slack with the token you provided."
  )
})

test_that("Echoing config works", {
  skip_on_cran()

  params <- list(
    SLACK_CHANNEL = "foo",
    SLACK_USERNAME = "bar",
    SLACK_ICON_EMOJI = "cowboy",
    SLACK_INCOMING_WEBHOOK_URL = "baz",
    SLACK_TOKEN = "qux"
  )

  foo <- capture.output(
    try({slackr_setup(
      token = params$SLACK_TOKEN,
      username = params$SLACK_USERNAME,
      channel = params$SLACK_CHANNEL,
      icon_emoji = params$SLACK_ICON_EMOJI,
      incoming_webhook_url = params$SLACK_INCOMING_WEBHOOK_URL,
      echo = TRUE
    )}, silent = TRUE)
  ) %>%
    paste(collapse = "") %>%
    fromJSON() %>%
    expect_identical(params)
})
