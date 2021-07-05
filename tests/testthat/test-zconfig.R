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
