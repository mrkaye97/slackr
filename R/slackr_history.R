#' Reads history of a channel.
#'
#' Returns a dataframe of post history in a channel.
#'
#' @section Scopes:
#'
#'   You need one or more of these scopes enabled in your slack app: *
#'   channels:history * groups:history * im:history * mpim:history
#'
#' @param token Authentication token bearing required scopes.
#' @param channel Channel, private group, or IM channel to send message to. Can be an encoded ID, or a name.
#' @param posted_from_time Timestamp of the first post time to consider. If both
#'   posted_to_time and duration is specifed, they take precedence.
#'   Corresponds to `oldest` in the \href{https://api.slack.com/methods/conversations.history}{conversations.history}
#'   docs.
#'   Default: 0
#' @param duration Number of hours of history to retrieve.  If neither `duration`
#'   nor `posted_from_time` is specified, there is no time limit on the retrieved
#'   history. (default: `NULL`)
#' @param posted_to_time Timestamp of the last post to consider.
#'   Corresponds to `latest` in the \href{https://api.slack.com/methods/conversations.history}{conversations.history} docs.
#'   Default: current time.
#' @param paginate If TRUE, uses the Slack API pagination mechanism, and will retrieve all history inside the timeframe.  Otherwise, makes a single call to the API and retrieves a maximum of `message_count` messages.
#' @param message_count The number of messages to retrieve (only when `paginate = FALSE`).
#'   Corresponds to `limit` in the \href{https://api.slack.com/methods/conversations.history}{conversations.history} docs.
#'   Note: If using pagination, setting a value of (e.g.) 1 will result in paginating
#'   through the channel's history one message at a time. Slack recommends using a value of 200.
#' @param inclusive Include messages with oldest or latest timestamps in results. Ignored unless either timestamp is specified.
#' @export
#'
#' @return A `tibble` with message metadata
#' @references <https://api.slack.com/methods/conversations.history>
#'
slackr_history <- function(
  message_count,
  channel = Sys.getenv("SLACK_CHANNEL"),
  token = Sys.getenv("SLACK_TOKEN"),
  posted_to_time = as.numeric(Sys.time()),
  duration = NULL,
  posted_from_time = 0,
  paginate = FALSE,
  inclusive = TRUE
) {
  channel <- slackr_chtrans(channel, token)

  if (!missing(duration) && !is.null(duration) && !missing(posted_to_time) && !is.null(posted_to_time)) {
    if (!missing(posted_from_time) & !is.null(posted_from_time)) {
      warn(
        paste(
          "You specified all three of `duration`, `posted_to_time`,",
          "and `posted_from_time`.",
          "Doing this makes `slackr` infer `posted_from_time`",
          "from a combination of the `duration` you specified and the",
          "`posted_to_time`.",
          "If you meant to retrieve history between your specified",
          "`posted_from_time` and `posted_to_time`, please remove",
          "the `duration` you specified."
        ),
        .frequency = "regularly",
        .frequency_id = "slackr_history_posted_from_infer_warning"
      )
    }
    posted_from_time <- posted_to_time - duration * 3600
  }

  if (!paginate) {
    resp <- call_slack_api(
      "/api/conversations.history",
      .method = GET,
      token = token,
      channel = channel,
      latest = posted_to_time,
      oldest = posted_from_time,
      inclusive = inclusive,
      limit = message_count
    )

    resp <- convert_response_to_tibble(resp, "messages")
  } else {
    if (missing(posted_from_time) | is.null(posted_to_time)) {
      abort(
        paste(
          "To use pagination with `slackr_history`, you must",
          "specify a value for `posted_from_time`.",
          "Not doing so will result in paginating through the entire",
          "history of the channel up to `posted_to_time`",
          "(i.e. from `posted_from_time = 0` until `posted_to_time`)."
        )
      )
    }

    resp <- with_pagination(
        function(cursor) {
          call_slack_api(
            "/api/conversations.history",
            .method = GET,
            token = token,
            channel = channel,
            latest = posted_to_time,
            oldest = posted_from_time,
            inclusive = inclusive,
            limit = message_count,
            .next_cursor = cursor
          )
        },
        extract = "messages"
      )
  }

  resp
}
