#' Lists all channels in a Slack team.
#'
#' @inheritParams list_channels
#'
#' @references https://api.slack.com/methods/conversations.list
#' @keywords internal
list_channels <- function(bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"), types = "public_channel", ...) {
  with_pagination(
    function() {
      call_slack_api(
        "/api/conversations.list",
        .method = GET,
        types = types,
        ...
      )
    },
    extract = "channels"
  )
}


#' Lists all users in a Slack team.
#'
#' @inheritParams list_channels
#' @references https://api.slack.com/methods/users.list
list_users <- function(bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"), ...) {
  with_pagination(
    function() {
      call_slack_api(
        "/api/users.list",
        .method = GET,
        ...
      )
    },
    extract = "members"
  )
}

#' Sends a message to a channel.
#'
#' @inheritParams list_channels
#' @references https://api.slack.com/methods/chat.postMessage
post_message <- function(txt, channel, bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"), ...) {
  with_pagination(
    function() {
      call_slack_api(
        "/api/chat.postMessage",
        .method = POST,
        body = list(
          text = txt,
          channel = slackr_chtrans(channel),
          as_user = TRUE
        )
      )
    },
    extract = "message"
  )
}
