#' Lists all channels in a Slack team.
#'
#' @inheritParams auth_test
#'
#' @param exclude_archived If TRUE, excludes archived channels.
#'
#' @return tibble of channels
#'
#' @keywords internal
#' @noRd
#' @references https://api.slack.com/methods/conversations.list
list_channels <- function(token, types, exclude_archived, ...) {
  with_pagination(
    function(cursor) {
      call_slack_api(
        "/api/conversations.list",
        .method = GET,
        token = token,
        types = types,
        exclude_archived = exclude_archived,
        limit = 1000,
        ...,
        .next_cursor = cursor
      )
    },
    extract = "channels"
  )
}


#' Lists all users in a Slack team.
#' @inheritParams auth_test
#' @keywords internal
#' @noRd
#' @references https://api.slack.com/methods/users.list
list_users <- function(token, ...) {
  with_pagination(
    function(cursor) {
      call_slack_api(
        "/api/users.list",
        .method = GET,
        token = token,
        ...,
        .next_cursor = cursor
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
#' @param txt Passed to `text` parameter of `chat.postMessage` API.
#' @param channel Channel, private group, or IM channel to send message to. Can be an encoded ID, or a name.
#' @param emoji Emoji to use as the icon for this message. Overrides icon_url. Must be used in conjunction with as_user (hard coded in `slackr`) set to false, otherwise ignored.
#' @param username Set your bot's user name. Must be used in conjunction with as_user set to false, otherwise ignored.
#' @param token A Slack API token.
#'
#' @references https://api.slack.com/methods/chat.postMessage
post_message <- function(
  txt,
  channel,
  emoji,
  username,
  token,
  ...
) {
  r <- call_slack_api(
      "/api/chat.postMessage",
      .method = POST,
      token = token,
      body = list(
        text = txt,
        channel = channel,
        username = username,
        link_names = 1,
        icon_emoji = emoji,
        ...
      )
    )

  invisible(content(r))
}





#' Uploads or creates a file.
#'
#' This needs the scope `files:write:user`
#'
#' @param file Name of file to upload.
#' @param channels Comma-separated list of channel names or IDs where the file will be shared.
#' @param initial_comment The message text introducing the file in specified channels.
#' @param token Authentication token bearing required scopes.
#' @param ... Additional arguments to be passed in the POST body to the `files.upload` endpoint. See the \href{https://api.slack.com/methods/files.upload}{files.upload endpoint documentation} for details.
#' @importFrom httr upload_file
#' @keywords internal
#' @noRd
#'
#'
#' @references https://api.slack.com/methods/files.upload
files_upload <- function(
  file,
  channels,
  initial_comment,
  token,
  ...
) {
  initial_upload_response <- call_slack_api(
    "/api/files.getUploadURLExternal",
    .method = POST,
    token = token,
    body = list(
      filename=file,
      length=file.size(file)
    )
  )

  initial_upload_content <- content(initial_upload_response)

  upload_url <- initial_upload_content$upload_url
  file_id <- initial_upload_content$file_id
  channel <- slackr_chtrans(channels, token)

  httr::POST(
    url=upload_url,
    body=upload_file(file)
  )

  kwargs <- list(...)
  title <- kwargs$title

  if (is.null(title)) {
    inner <- list(id = file_id)
  } else {
    inner <- list(id = file_id, title = title)
  }

  response <- httr::POST(
    "https://slack.com/api/files.completeUploadExternal",
    add_headers(
      .headers = c(Authorization = paste("Bearer", token))
    ),
    httr::content_type_json(),
    encode="json",
    body = list(
      files = list(inner),
      channel_id=channel,
      initial_comment=initial_comment,
      ...
    )
  )

  invisible(content(response))
}


list_scopes <- function(token) {
  r <- call_slack_api(
    "/api/apps.permissions.scopes.list",
    .method = GET,
    token = token
  )
  invisible(content(r))
}
