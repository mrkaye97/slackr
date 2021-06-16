#' slackr_delete
#'
#' Deletes the specified number of messages from the channel
#' @param count the number of messages to delete
#' @param channel the channel to delete from
#' @param token A Slack token (either a user token or a bot user token)
#' @param bot_user_oauth_token Deprecated. A Slack bot user OAuth token
#' @export
slackr_delete <- function(count,
                          channel = Sys.getenv("SLACK_CHANNEL"),
                          token = Sys.getenv("SLACK_TOKEN"),
                          bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {
  token <- check_tokens(token, bot_user_oauth_token)

  if (!is.character(channel) | length(channel) > 1) {
    abort("channel must be a character vector of length one")
  }
  if (!is.character(token) | length(token) > 1) {
    abort("token must be a character vector of length one")
  }
  channel <- slackr_chtrans(channel, token)

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
