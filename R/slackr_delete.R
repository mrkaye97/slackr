#' slackr_delete
#'
#' Deletes the specified number of messages from the channel
#' @param count the number of messages to delete
#' @param channel the channel to delete from
#' @param token the Slack bot user OAuth token
#' @export
slackr_delete <- function(count,
                          channel = Sys.getenv("SLACK_CHANNEL"),
                          token = Sys.getenv("SLACK_TOKEN"),
                          bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {

  if (bot_user_oauth_token != "") warn("The use of `bot_user_oauth_token` is deprecated as of `slackr 3.0.0`. Please use `token` instead.")

  if (!is.character(channel) | length(channel) > 1) {
    abort("channel must be a character vector of length one")
  }
  if (!is.character(token) | length(token) > 1) {
    abort("token must be a character vector of length one")
  }

  timestamps <- slackr_history(channel = channel, message_count = count, paginate = FALSE)[["ts"]]

  resp <- lapply(timestamps, function(ts) {
    r <- call_slack_api(
      "/api/chat.delete",
      token = token,
      .method = POST,
      body = list(
        channel = channel,
        ts = ts
      )
    )
    content(r)
  })

  invisible(resp)
}
