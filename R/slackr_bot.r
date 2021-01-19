#' Send result of R expressions to a Slack channel via webhook API
#'
#' Takes an `expr`, evaluates it and sends the output to a Slack
#' chat destination via the webhook API. Useful for logging, messaging on long
#' compute tasks or general information sharing.
#'
#' By default, everyting but `expr` will be looked for in a "`SLACK_`"
#' environment variable. You can override or just specify these values directly
#' instead, but it's probably better to call [slackr_setup()] first.
#'
#' This function uses the incoming webhook API. The webhook will have a default
#' channel, username, icon etc, but these can be overridden.
#'
#' @param ... expressions to be sent to Slack
#' @param channel which channel to post the message to (chr)
#' @param username what user should the bot be named as (chr)
#' @param icon_emoji what emoji to use (chr) `""` will mean use the default
#' @param incoming_webhook_url which `slack.com` API endpoint URL to use
#'   (see section **Webhook URLs** for details)
#' @note You need a <https://www.slack.com> account and will also need to
#'   setup an incoming webhook: <https://api.slack.com/>. Old style webhooks are
#'   no longer supported.
#' @seealso [slackrSetup()], [slackr()],
#'   [dev_slackr()], [save_slackr()],
#'   [slackr_upload()]
#' @rdname slackr_bot
#' @section Webhook URLs: Webhook URLs look like: \itemize{
#'
#'   \item `https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX`
#'
#'   }
#'
#' OLD STYLE WEBHOOKS ARE NO LONGER SUPPORTED
#'
#' @examples
#' \dontrun{
#' slackr_setup()
#' slackr_bot("iris info", head(iris), str(iris))
#'
#' # or directly
#' slackr_bot("Test message", username="slackr", channel="#random",
#'   incoming_webhook_url="https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX")
#' }
#' @export
slackr_bot <- function(...,
                       channel=Sys.getenv("SLACK_CHANNEL"),
                       username=Sys.getenv("SLACK_USERNAME"),
                       icon_emoji=Sys.getenv("SLACK_ICON_EMOJI"),
                       incoming_webhook_url=Sys.getenv("SLACK_INCOMING_URL_PREFIX")) {

  if (incoming_webhook_url == "") {
    stop("No incoming webhook URL specified. Did you forget to call slackr_setup()?", call. = FALSE)
  }

  if (icon_emoji != "") { icon_emoji <- sprintf(', "icon_emoji": "%s"', icon_emoji)  }

  resp_ret <- ""

  if (!missing(...)) {

    # mimics capture.output

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
        # if it's actually an expression, iterate over it
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
        stop("mode of argument not handled at present by slackr")
      )

      for (item in tmp) if (item$visible) { print(item$value, quote = FALSE); cat("\n") }
    }

    on.exit()

    sink()
    close(fil)

    # combined all of them (rval is a character vector)
    output <- paste0(rval, collapse="\n")

    loc <- Sys.getlocale('LC_CTYPE')
    Sys.setlocale('LC_CTYPE','C')
    on.exit(Sys.setlocale("LC_CTYPE", loc))

    resp <- POST(
      url = incoming_webhook_url,
      encode = "form",
      add_headers(
        `Content-Type` = "application/x-www-form-urlencoded",
        Accept = "*/*"
        ),
      body = URLencode(
        sprintf(
          "payload={\"channel\": \"%s\", \"username\": \"%s\", \"text\": \"```%s```\"%s}",
          channel, username, output, icon_emoji)
        )
      )
    stop_for_status(resp)
  }
  return(invisible(resp))
}
