#' Lists all channels in a Slack team.
#'
#' @inheritParams auth_test
#' @keywords internal
#' @noRd
#' @references https://api.slack.com/methods/conversations.list
list_channels <- function(bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"), types = "public_channel", ...) {
  with_pagination(
    function() {
      call_slack_api(
        "/api/conversations.list",
        .method = GET,
        bot_user_oauth_token = bot_user_oauth_token,
        types = types,
        ...
      )
    },
    extract = "channels"
  )
}


#' Lists all users in a Slack team.
#'
#' @inheritParams auth_test
#' @keywords internal
#' @noRd
#' @references https://api.slack.com/methods/users.list
list_users <- function(bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"), ...) {
  with_pagination(
    function() {
      call_slack_api(
        "/api/users.list",
        .method = GET,
        bot_user_oauth_token = bot_user_oauth_token,
        ...
      )
    },
    extract = "members"
  )
}

#' Sends a message to a channel.
#'
#' @inheritParams auth_test
#' @keywords internal
#' @noRd
#'
#' @param txt Passed to `text` parameter of `chat.postMessage` API
#' @param emoji Emoji
#' @param channel Passed to `channel` parameter of `chat.postMessage` API
#' @param username Passed to `username` parameter of `chat.postMessage` API
#' @param as_user Passed to `as_user` parameter of `chat.postMessage` API
#' @param link_names Passed to `link_names` parameter of `chat.postMessage` API
#'
#' @references https://api.slack.com/methods/chat.postMessage
post_message <- function(
  txt,
  channel,
  emoji = "",
  username = Sys.getenv("SLACK_USERNAME"),
  bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"),
  ...)
{
  z <-
    call_slack_api(
    "/api/chat.postMessage",
    .method = POST,
    bot_user_oauth_token = bot_user_oauth_token,
    body = list(
      text       = txt,
      channel    = slackr_chtrans(channel),
      username   = username,
      as_user    = TRUE,
      link_names = 1,
      icon_emoji = emoji,
      ...
    )
  )
  invisible(content(z))
}





#' Uploads or creates a file.
#'
#' This needs the scope `files:write:user`
#'
#' @inheritParams auth_test
#' @inheritParams post_message
#'
#' @param file Name of file to upload
#'
#' @keywords internal
#' @noRd
#'
#'
#' @references https://api.slack.com/methods/files.upload
files_upload <- function(
  file,
  channel,
  txt = "",
  username = Sys.getenv("SLACK_USERNAME"),
  bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"),
  ...)
{
  z <- call_slack_api(
    "/api/files.upload",
    .method = POST,
    bot_user_oauth_token = bot_user_oauth_token,
    body = list(
      file            = httr::upload_file(file),
      initial_comment = txt,
      channels        = slackr_chtrans(channel),
      username        = username,
      ...
    )
  )
  invisible(content(z))
}


list_scopes <- function(bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {
  z <- call_slack_api(
    "/api/apps.permissions.scopes.list",
    .method = GET,
    bot_user_oauth_token = bot_user_oauth_token
  )
  invisible(content(z))
}

