
getAPIToken <- function(){
  if(Sys.getenv("SLACK_API_TOKEN") == ""){
    # This only works when you run locally. slacr_creds.yml should not be saved in git.
    # Travis should use the env variable
    creds_file <- file.path(system.file(package = "slackr"),"exdata", "slackr_creds.yml")
    if(file.exists(creds_file)) {
      api_token <- yaml::read_yaml(creds_file)$slackr$api_token
      Sys.setenv("SLACK_API_TOKEN" = api_token)
    } else {
      stop("No local credentials file found")
    }
  } else {
    api_token <- Sys.getenv("SLACK_API_TOKEN")
  }
  return(api_token)
}
api_token <- getAPIToken()


test_that("slackr_msg: failure when not setup yet", {
  # On github, should be done with Env variable.

  #NB: Bot must be invited to channel by user.
  expect_error(
    slackr::slackr_msg(txt = paste("testing: ", Sys.time()),
                       channel = "#publicchanneltest"),
    regexp = "slackr_census "
    )
})

test_that("slackr_setup works ", {
  expect_silent(slackr_setup(channel = "#publicchanneltest",
                             username = "slackr_bot",
                             api_token = api_token ))
})


getWebhook <- function(){
  if(Sys.getenv("SLACK_WEBHOOK") == ""){
    # This only works when you run locally. slacr_creds.yml should not be saved in git.
    # Travis should use the env variable
    creds_file <- file.path(system.file(package = "slackr"),"exdata", "slackr_creds.yml")
    if(file.exists(creds_file)) {
      webhook <- yaml::read_yaml(creds_file)$slackr$webhook
      Sys.setenv("SLACK_WEBHOOK" = webhook)
    } else {
      stop("No local credentials file found")
    }
  } else {
    webhook <- Sys.getenv("SLACK_WEBHOOK")
  }
  return(webhook)
}
webhook <- getWebhook()

test_that("slackr_setup works ", {
  expect_silent(slackr_setup(channel = "#publicchanneltest",
                             username = "slackr_bot",
                             api_token = api_token ))
})
