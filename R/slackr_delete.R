#' slackr_delete
#'
#' Deletes the specified number of messages from the channel
#' @param count The number of messages to delete.
#' @param channel Channel, private group, or IM channel to delete messages from. Can be an encoded ID, or a name. See the \href{https://api.slack.com/methods/chat.postMessage#channels}{chat.postMessage endpoint documentation} for details.
#' @param token Authentication token bearing required scopes.
#' @export
slackr_delete <- function(
  count,
  channel = Sys.getenv("SLACK_CHANNEL"),
  token = Sys.getenv("SLACK_TOKEN")
) {
  if (!is.character(channel) | length(channel) > 1) {
    abort("channel must be a character vector of length one")
  }
  if (!is.character(token) | length(token) > 1) {
    abort("token must be a character vector of length one")
  }

  channel_translated <- slackr_chtrans(channel, token)

  timestamps <- slackr_history(channel = channel, message_count = count, paginate = FALSE)[["ts"]]

  resp <- lapply(timestamps, function(ts) {
    r <- call_slack_api(
      "/api/chat.delete",
      token = token,
      .method = POST,
      body = list(
        channel = channel_translated,
        ts = ts
      )
    )
    content(r)
  })

  invisible(resp)
}
