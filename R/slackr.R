#' Output R expressions to a Slack channel/user
#'
#' Takes an `expr`, evaluates it and sends the output to a Slack
#' chat destination. Useful for logging, messaging on long compute tasks or
#' general information sharing.
#'
#' By default, everything but `expr` will be looked for in a "`SLACK_`"
#' environment variable. You can override or just specify these values directly instead,
#' but it's probably better to call [slackr_setup()] first.
#' @importFrom withr local_options
#' @importFrom rlang call2
#' @param ... expressions to be sent to Slack.
#' @param channel Channel, private group, or IM channel to send message to. Can be an encoded ID, or a name. See the \href{https://api.slack.com/methods/chat.postMessage#channels}{chat.postMessage endpoint documentation} for details.
#' @param username what user should the bot be named as (chr).
#' @param icon_emoji what emoji to use (chr) `""` will mean use the default.
#' @param token Authentication token bearing required scopes.
#' @param thread_ts Provide another message's ts value to make this message a reply. Avoid using a reply's ts value; use its parent instead.
#' @param reply_broadcast Used in conjunction with thread_ts and indicates whether reply should be made visible to everyone in the channel or conversation. Defaults to FALSE.
#' @return the response (invisibly)
#' @note You need a <https://www.slack.com> account and will also need to
#'       set up an API token <https://api.slack.com/>
#' @seealso [slackr_setup()], [slackr_bot()], [slackr_dev()],
#'          [slackr_save()], [slackr_upload()]
#' @examples
#' \dontrun{
#' slackr_setup()
#' slackr("iris info", head(iris), str(iris))
#' }
#' @export
slackr <- function(...,
                   channel = Sys.getenv("SLACK_CHANNEL"),
                   username = Sys.getenv("SLACK_USERNAME"),
                   icon_emoji = Sys.getenv("SLACK_ICON_EMOJI"),
                   token = Sys.getenv("SLACK_TOKEN"),
                   thread_ts = NULL,
                   reply_broadcast = FALSE) {

  local_options(list(cli.num_colors = 1))

  warn_for_args(
    token,
    username = username,
    icon_emoji = icon_emoji
  )

  if (!missing(...)) {

    # get the arglist
    args <- substitute(list(...))[-1L]

    modes_to_not_prex <- c("integer", "double", "complex", "raw", "logical", "character", "numeric")

    ## map over each thing passed to `slackr` and evaluate it
    output <- lapply(
      args,
      function(.x) {
        if (mode(.x) %in% modes_to_not_prex) {
          .x
        } else {
          inform(
            "slackr now relies on `reprex` for rendering.\nRendering messages will print, and reprex output will be saved to the clipboard.\nYou can directly paste the results into Slack.\n\n",
            .frequency = "once",
            .frequency_id = "36531017-f90e-4e39-8e39-4c9042634cb7"
          )
          eval(call2(prex_r, .x, input = tempfile(), html_preview = FALSE, render = TRUE, style = FALSE))
        }
      }
    ) %>%
      lapply(
        function(.x) {
          if (mode(.x) %in% modes_to_not_prex) {
            .x
          } else {
            .x <- .x$result
            .x[1] <- paste(">", .x[1])
            paste(.x, collapse = "\n")
          }
        }
      ) %>%
      paste(collapse = "\n\n")

    if ((Sys.getenv("SLACKR_ERRORS") != "IGNORE") && grepl("Error: ", output)) {
      error_message <- sprintf(
        "Found a (potential) error in `slackr` call. Attempt at parsing the error:\n\n  %s\n\nWe tried to extract the call for you too:\n\n  %s\n\nNo message was posted.\nYou can ignore this warning and post the message with `Sys.setenv('SLACKR_ERRORS' = 'IGNORE')`.\n\n",
        gsub("\n", "\n  ", output),
        deparse(sys.call())
      )

      abort(
        error_message
      )
    } else {
      resp <-
        post_message(
          token = token,
          channel = channel,
          username = username,
          emoji = icon_emoji,
          txt = sprintf("```%s```", output),
          link_names = 1,
          thread_ts = thread_ts,
          reply_broadcast = reply_broadcast
        )
    }
  }

  invisible(resp)
}

#' Sends a message to a slack channel.
#'
#' @param txt text message to send to Slack. If a character vector of length > 1
#'        is passed in, they will be combined and separated by newlines.
#' @param channel Channel, private group, or IM channel to send message to. Can be an encoded ID, or a name. See the \href{https://api.slack.com/methods/chat.postMessage#channels}{chat.postMessage endpoint documentation} for details.
#' @param username what user should the bot be named as (chr).
#' @param icon_emoji what emoji to use (chr) `""` will mean use the default.
#' @param token Authentication token bearing required scopes.
#' @param thread_ts Provide another message's ts value to make this message a reply. Avoid using a reply's ts value; use its parent instead.
#' @param reply_broadcast Used in conjunction with thread_ts and indicates whether reply should be made visible to everyone in the channel or conversation. Defaults to FALSE.
#' @param ... other arguments passed to the Slack API `chat.postMessage` call
#' @return the response (invisibly)
#' @note You need a <https://www.slack.com> account and will also need to
#'       setup an API token <https://api.slack.com/>
#'       Also, you can pass in `add_user=TRUE` as part of the `...`
#'       parameters and the Slack API will post the message as your logged-in
#'       user account (this will override anything set in `username`)
#' @seealso [slackr_setup()], [slackr_bot()], [slackr_dev()],
#'          [slackr_save()], [slackr_upload()]
#' @examples
#' \dontrun{
#' slackr_setup()
#' slackr_msg("Hi")
#' }
#' @export
slackr_msg <- function(txt = "",
                       channel = Sys.getenv("SLACK_CHANNEL"),
                       username = Sys.getenv("SLACK_USERNAME"),
                       icon_emoji = Sys.getenv("SLACK_ICON_EMOJI"),
                       token = Sys.getenv("SLACK_TOKEN"),
                       thread_ts = NULL,
                       reply_broadcast = FALSE,
                       ...) {
  warn_for_args(
    token,
    username = username,
    icon_emoji = icon_emoji
  )

  output <- paste0(txt, collapse = "\n\n")

  z <-
    post_message(
      txt        = output,
      emoji = icon_emoji,
      channel    = channel,
      token = token,
      username = username,
      link_names = 1,
      thread_ts = thread_ts,
      reply_broadcast = reply_broadcast,
      ...
    )

  invisible(z)
}
