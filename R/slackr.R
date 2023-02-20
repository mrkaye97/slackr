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
slackr <- function(
  ...,
  channel = Sys.getenv("SLACK_CHANNEL"),
  username = Sys.getenv("SLACK_USERNAME"),
  icon_emoji = Sys.getenv("SLACK_ICON_EMOJI"),
  token = Sys.getenv("SLACK_TOKEN"),
  thread_ts = NULL,
  reply_broadcast = FALSE
) {
  local_options(list(cli.num_colors = 1))

  warn_for_args(
    token,
    username = username,
    icon_emoji = icon_emoji
  )

  if (!missing(...)) {
    # get the arglist
    args <- substitute(list(...))[-1L]

    # setup in-memory sink
    rval <- NULL
    fil <- textConnection("rval", "w", local = TRUE)

    sink(fil)
    on.exit({
      sink()
      close(fil)
    })

    # where we'll need to eval expressions
    pf <- parent.frame()

    # how we'll eval expressions
    evalVis <- function(expr) withVisible(eval(expr, pf))

    # for each expression
    for (i in seq_along(args)) {
      expr <- args[[i]]

      # do something, note all the newlines...Slack ``` needs them
      tmp <- switch(
        mode(expr),
        # if it's actually an expresison, iterate over it
        expression = {
          cat(sprintf("> %s\n", deparse(expr)))
          lapply(expr, evalVis)
        },
        # if it's a call or a name, eval, printing run output as if in console
        call = ,
        name = {
          cat(sprintf("> %s\n", deparse(expr)))
          list(evalVis(expr))
        },
        # if pretty much anything else (i.e. a bare value) just output it
        integer = ,
        double = ,
        complex = ,
        raw = ,
        logical = ,
        numeric = cat(sprintf("%s\n\n", as.character(expr))),
        character = cat(sprintf("%s\n\n", expr)),
        abort("mode of argument not handled at present by slackr")
      )

      for (item in tmp) {
        if (item$visible) {
          print(item$value)
          cat("\n")
        }
      }
    }

    on.exit()

    sink()
    close(fil)

    # combined all of them (rval is a character vector)
    output <- paste0(rval, collapse = "\n")

    resp <- post_message(
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
slackr_msg <- function(
  txt = "",
  channel = Sys.getenv("SLACK_CHANNEL"),
  username = Sys.getenv("SLACK_USERNAME"),
  icon_emoji = Sys.getenv("SLACK_ICON_EMOJI"),
  token = Sys.getenv("SLACK_TOKEN"),
  thread_ts = NULL,
  reply_broadcast = FALSE,
  ...
) {
  warn_for_args(
    token,
    username = username,
    icon_emoji = icon_emoji
  )

  output <- paste0(txt, collapse = "\n\n")

  z <- post_message(
    txt = output,
    emoji = icon_emoji,
    channel = channel,
    token = token,
    username = username,
    link_names = 1,
    thread_ts = thread_ts,
    reply_broadcast = reply_broadcast,
    ...
  )

  invisible(z)
}
