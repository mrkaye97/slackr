#' Output R expressions to a \code{slack.com} channel/user (as \code{slackbot})
#'
#' Takes an \code{expr}, evaluates it and sends the output to a \code{slack.com}
#' chat destination. Useful for logging, messaging on long compute tasks or
#' general information sharing.
#'
#' By default, everyting but \code{expr} will be looked for in a "\code{SLACK_}"
#' environment variable. You can override or just specify these values directly
#' instead, but it's probably better to call \code{\link{slackrSetup}} first.
#'
#' This function uses the incoming webhook API and posts user messages as
#' \code{slackbot}
#'
#' @param ... expressions to be sent to Slack.com
#' @param channel which channel to post the message to (chr)
#' @param username what user should the bot be named as (chr)
#' @param icon_emoji what emoji to use (chr) \code{""} will mean use the default
#' @param incoming_webhook_url which \code{slack.com} API endpoint URL to use
#'   (see section \bold{Webhook URLs} for details)
#' @param token your webhook API token (see section \bold{Webhook URLs} for
#'   details)
#' @note You need a \url{https://www.slack.com} account and will also need to
#'   setup an incoming webhook: \url{https://api.slack.com/}
#' @seealso \code{\link{slackrSetup}}, \code{\link{slackr}},
#'   \code{\link{dev_slackr}}, \code{\link{save_slackr}},
#'   \code{\link{slackr_upload}}
#' @rdname slackr_bot
#' @section Webhook URLs: Webhook URLs look like: \itemize{
#'
#'   \item \code{http://myslack.slack.com/services/hooks/incoming-webhook?}
#'
#'   \item \code{https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX}
#'
#'   }
#'
#'   The second, \emph{new}, style is the standard form at the time of writing
#'   (August 2015). If you have an an old style webhook URL then you must alos
#'   supply a \code{token}. If you have a new style URL, then no \code{token} is
#'   required.
#' @examples
#' \dontrun{
#' slackr_setup()
#' slackr_bot("iris info", head(iris), str(iris))
#'
#' # or directly
#' slackr_bot("Test message", username="slackr", channel="#random",
#'   incoming_webhook_url="https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX")
#'
#' # ... with an old style webhook API URL
#' slackr_bot("Test message", username="slackr", channel="#random",
#'   incoming_webhook_url="http://myslack.slack.com/services/hooks/incoming-webhook?",
#'   token="XXXXXXXXXXXXXX")
#' }
#' @export
slackr_bot <- function(...,
                       channel=Sys.getenv("SLACK_CHANNEL"),
                       username=Sys.getenv("SLACK_USERNAME"),
                       icon_emoji=Sys.getenv("SLACK_ICON_EMOJI"),
                       incoming_webhook_url=Sys.getenv("SLACK_INCOMING_URL_PREFIX"),
                       token=Sys.getenv("SLACK_TOKEN")) {

  if (incoming_webhook_url == "") {
    stop("No incoming webhook URL specified. Did you forget to call slackrSetup()?", call. = FALSE)
  }
  oldstyle_webhook=!grepl("https://hooks.slack.com/services/",incoming_webhook_url, fixed=T)

  if(oldstyle_webhook && token == "") {
    stop("No webhook token specified. Did you forget to call slackrSetup()?", call. = FALSE)
  }

  if (icon_emoji != "") { icon_emoji <- sprintf(', "icon_emoji": "%s"', icon_emoji)  }

  resp_ret <- ""

  if (!missing(...)) {

    input_list <- as.list(substitute(list(...)))[-1L]

    for(i in 1:length(input_list)) {

      expr <- input_list[[i]]

      if (class(expr) == "call") {

        expr_text <- sprintf("> %s", deparse(expr))

        data <- capture.output(eval(expr))
        data <- paste0(data, collapse="\n")
        data <- sprintf("%s\n%s", expr_text, data)

      } else {
        data <- as.character(expr)
      }

      output <- gsub('^\"|\"$', "", toJSON(data, simplifyVector=TRUE, flatten=TRUE, auto_unbox=TRUE))

      resp <- POST(url=ifelse(oldstyle_webhook,
                              paste0(incoming_webhook_url, "token=", token),
                              incoming_webhook_url),
                   add_headers(`Content-Type`="application/x-www-form-urlencoded", `Accept`="*/*"),
                   body=URLencode(sprintf('payload={"channel": "%s", "username": "%s", "text": "```%s```"%s}',
                                          channel, username, output, icon_emoji)))

      warn_for_status(resp)

      if (resp$status_code > 200) { print(str(expr))}

    }

  }

  return(invisible())

}

#' @rdname slackr_bot
#' @export
slackrBot <- slackr_bot

#' @rdname slackr_bot
#' @export
slackbot <- slackr_bot
