#' Reads history of a channel.
#'
#' Returns a dataframe of post history in a channel.
#'
#' @section Scopes:
#'
#'   You need one or more of these scopes enabled in your slack app: *
#'   channels:history * groups:history * im:history * mpim:history
#'
#' @param bot_user_oauth_token the Slack bot user OAuth token
#' @param channel The channel to get history from
#' @param posted_from_time Timestamp of the first post time to consider
#' @param duration Number of hours of history to retrieve.  By default retrieves
#'   24 hours of history.
#' @param posted_to_time Timestamp of the last post to consider (default:
#'   current time)
#' @param paginate If TRUE, uses the Slack API pagination mechanism, and will retrieve all history inside the timeframe.  Otherwise, makes a single call to teh API and retrieves a maximum of `message_count` messages
#' @param message_count The number of messages to retrieve (only when `paginate = FALSE`)
#' @export
#'
#' @return A `tibble` with message metadata
#' @references <https://api.slack.com/methods/conversations.history>
#'
slackr_history <- function(
  channel = Sys.getenv("SLACK_CHANNEL"),
  bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"),
  posted_to_time = as.numeric(Sys.time()),
  message_count,
  duration,
  posted_from_time,
  paginate = FALSE
) {

  if (!missing(duration) && !is.null(duration) && !missing(posted_from_time) && !is.null(posted_from_time)) {
    posted_from_time <- posted_to_time - duration * 3600
  } else {
    posted_from_time <-  ""
  }

  resp <-
    if (!paginate) {
      resp <- call_slack_api(
        "/api/conversations.history",
        .method   = GET,
        bot_user_oauth_token = bot_user_oauth_token,
        channel   = channel,
        latest    = posted_to_time,
        oldest    = posted_from_time,
        inclusive = "true",
        limit     = message_count
      )
      convert_response_to_tibble(resp, "messages")
    } else {
      with_pagination(
        function(cursor) {
          call_slack_api(
            "/api/conversations.history",
            .method   = GET,
            bot_user_oauth_token = bot_user_oauth_token,
            channel   = channel,
            latest    = posted_to_time,
            oldest    = posted_from_time,
            inclusive = "true",
            limit     = message_count,
            .next_cursor = cursor
          )
        },
        extract = "messages"
      )
    }
  resp
}
