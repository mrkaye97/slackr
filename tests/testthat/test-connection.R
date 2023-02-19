test_that("Initial setup completes", {
  skip_on_cran()

  expect_equal(
    if (Sys.getenv("ENVIRONMENT") == "production") {
      slackr_setup(
        channel = Sys.getenv("SLACK_CHANNEL"),
        username = Sys.getenv("SLACK_USERNAME"),
        icon_emoji = Sys.getenv("SLACK_ICON_EMOJI"),
        incoming_webhook_url = Sys.getenv("SLACK_INCOMING_WEBHOOK_URL"),
        token = Sys.getenv("SLACK_TOKEN")
      )
    } else {
      slackr_setup(
        config_file = "~/.slackr_config"
      )
    },
    "Successfully connected to Slack"
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

test_that("slackr_teardown removes env vars", {
  skip_on_cran()

  slackr_teardown()

  expect_identical(Sys.getenv("SLACK_TOKEN"), "")
  expect_identical(Sys.getenv("SLACK_CHANNEL"), "")
  expect_identical(Sys.getenv("SLACK_USERNAME"), "")
  expect_identical(Sys.getenv("SLACK_INCOMING_WEBHOOK_URL"), "")
  expect_identical(Sys.getenv("SLACK_ICON_EMOJI"), "")
})

test_that("slackr_setup() connects", {
  skip_on_cran()

  expect_equal(
    slackr_setup(
      channel = "#test",
      token = Sys.getenv("SLACK_TOKEN"),
      incoming_webhook_url = Sys.getenv("SLACK_INCOMING_WEBHOOK_URL"),
      username = "slackr",
      icon_emoji = "robot_face"
    ),
    "Successfully connected to Slack"
  )

  expect_true(
    grepl("^xox.-", Sys.getenv("SLACK_TOKEN"))
  )

  expect_true(
    grepl("^https://hooks", Sys.getenv("SLACK_INCOMING_WEBHOOK_URL"))
  )

  expect_equal(
    Sys.getenv("SLACK_CHANNEL"),
    "#test"
  )
})

test_that("config file setup works", {
  skip_on_cran()

  tmp <- tempfile(fileext = ".dcf")
  create_config_file(
    filename = tmp,
    token = Sys.getenv("SLACK_TOKEN"),
    channel = Sys.getenv("SLACK_CHANNEL"),
    username = Sys.getenv("SLACK_USERNAME"),
    incoming_webhook_url = Sys.getenv("SLACK_INCOMING_WEBHOOK_URL"),
    icon_emoji = Sys.getenv("SLACK_ICON_EMOJI")
  )

  expect_equal(
    slackr_setup(config_file = tmp),
    "Successfully connected to Slack"
  )
})
