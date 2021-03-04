#' slackr_delete
#'
#' Deletes the specified number of messages from the channel
#' @param count the number of messages to delete
#' @param channel the channel to delete from
#' @param bot_user_oauth_token the Slack bot user OAuth token
#' @export
slackr_delete <- function(
  count,
  channel=Sys.getenv("SLACK_CHANNEL"),
  bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")
) {

  if ( !is.character(channel) | length(channel) > 1 ) {
    stop("channel must be a character vector of length one")
    }
  if ( !is.character(bot_user_oauth_token) | length(bot_user_oauth_token) > 1 ) {
    stop("bot_user_oauth_token must be a character vector of length one")
  }

  channel <- slackr_chtrans(channel)

  timestamps <- slackr_history(channel = channel, message_count = count, paginate = FALSE)[["ts"]]

  resp <- lapply(timestamps, function(ts) {
    r <- call_slack_api(
      "/api/chat.delete",
      bot_user_oauth_token = bot_user_oauth_token,
      .method = POST,
      body = list(
        channel = channel,
        ts      = ts
      )
    )
    content(r)
  })

  invisible(resp)
}
