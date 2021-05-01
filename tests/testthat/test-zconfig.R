test_that("teardown works", {
  skip_on_cran()
  slackr_teardown()

  env_vars <- c(
    'SLACK_BOT_USER_OAUTH_TOKEN',
    'SLACK_CACHE_DIR',
    'SLACK_CHANNEL',
    'SLACK_ICON_EMOJI',
    'SLACK_INCOMING_URL_PREFIX',
    'SLACK_USERNAME')

  lapply(
    env_vars,
    function(x) expect_equal(Sys.getenv(x), '')
  )
})

test_that("config file write works", {
  skip_on_cran()

  tmp <- tempfile()
  create_config_file(tmp)

  slackr_teardown()

  env_vars <- c(
    'SLACK_BOT_USER_OAUTH_TOKEN',
    'SLACK_CACHE_DIR',
    'SLACK_CHANNEL',
    'SLACK_ICON_EMOJI',
    'SLACK_INCOMING_URL_PREFIX',
    'SLACK_USERNAME')

  lapply(
    env_vars,
    function(x) expect_equal(Sys.getenv(x), '')
  )

  expect_equal(
    slackr_setup(config_file = tmp),
    'Successfully connected to Slack'
  )
})
