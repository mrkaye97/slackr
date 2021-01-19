#' slackr_history
#'
#' Returns a dataframe of post history in a channel
#' @param bot_user_oauth_token the Slack bot user OAuth token
#' @param channel the channel to get history from
#' @param posted_from_time the first post time to consider (default: time = 0)
#' @param posted_to_time the last post time to consider (default: current time)
#' @param message_count the number of messages to retain
#' @importFrom jsonlite fromJSON
#' @importFrom httr POST content
#' @export
#'
slackr_history <- function(bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"),
                           channel = Sys.getenv("SLACK_CHANNEL"),
                           posted_from_time = 0L,
                           posted_to_time = as.numeric(Sys.time()),
                           message_count = 100L) {
  out <- tryCatch({
    chnl <- slackr_chtrans(channel)
    params <- list(token = bot_user_oauth_token,
                   channel = chnl,
                   latest = posted_to_time,
                   oldest = posted_from_time,
                   inclusive = "true",
                   count = message_count)

    response <- POST(url = "https://slack.com/api/conversations.history",
                          query = params)

    fromJSON(content(response, as = "text"))$messages
  }, error = function(e) {
    message(paste("Channel", channel, "does not exist."))
    message(e)
  })

  return(out)
}
