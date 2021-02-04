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
#'
#' @param ... expressions to be sent to Slack
#' @param incoming_webhook_url which `slack.com` API endpoint URL to use
#'   (see section **Webhook URLs** for details)
#' @param channel Deprecated. will have no effect
#' @param username Deprecated. will have no effect
#' @param icon_emoji Deprecated. will have no effect
#' @importFrom utils URLencode
#' @note You need a <https://www.slack.com> account and will also need to
#'   setup an incoming webhook: <https://api.slack.com/>. Old style webhooks are
#'   no longer supported.
#' @seealso [slackrSetup()], [slackr()],
#'   [dev_slackr()], [save_slackr()],
#'   [slackr_upload()]
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
                       channel = '',
                       username = '',
                       icon_emoji = '',
                       incoming_webhook_url=Sys.getenv("SLACK_INCOMING_URL_PREFIX")) {

  if (incoming_webhook_url == "") {
    stop("No incoming webhook URL specified. Did you forget to call slackr_setup()?", call. = FALSE)
  }

  if (channel != '') warning('The channel argument is deprecated as of slackr 2.1.1, as it no longer has any effect when used with a webhook')
  if (username != '') warning('The username argument is deprecated as of slackr 2.1.1, as it no longer has any effect when used with a webhook')
  if (icon_emoji != '') warning('The icon_emoji argument is deprecated as of slackr 2.1.1, as it no longer has any effect when used with a webhook')

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
          "payload={\"text\": \"```%s```\"}",
          output)
        )
      )
    stop_for_status(resp)
  }
  return(invisible(resp))
}
