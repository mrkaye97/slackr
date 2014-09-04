#' Setup environment variables for Slack.com API
#'
#' Initialize all the environment variables \code{slackr()} will need to use to
#' work properly.
#'
#' By default, \code{slackr} will use the \code{#general} room and a username
#' of \code{slackr()} with no emoji and the default slack.com API prefix URL. You
#' still need to provide the webhook API token in \code{token} for anyting to work.
#' Failure to call this function before calling \code{slackr()} will result in a
#' message to do so.
#'
#' @param channel which default channel to send the output to (chr) defaults to \code{#general}
#' @param username which username will output appear from (chr) defaults to \code{slackr}
#' @param icon_emoji which emoji picture to use (chr) defaults to none
#' @param token the slack.com API token string (chr) defaults to none
#' @param url_prefix the slack.com URL prefix to use (chr) defaults to none
#' @examples
#' \dontrun{
#' slackrSetup(channel="#code", url_prefix="http://myslack.slack.com/services/hooks/incoming-webhook?")
#' }
#' @export
slackrSetup <- function(channel="#general", username="slackr",
                        icon_emoji="", token="", url_prefix="") {

  Sys.setenv(SLACK_CHANNEL=channel)
  Sys.setenv(SLACK_USERNAME=username)
  Sys.setenv(SLACK_ICON_EMOJI=icon_emoji)
  Sys.setenv(SLACK_TOKEN=token)
  Sys.setenv(SLACK_URL_PREFIX=url_prefix)

}

#' Output R expressions to a Slack.com channel/user
#'
#' Takes an \code{expr}, evaluates it and sends the output to a Slack.com
#' chat destination. Useful for logging, messaging on long compute tasks or
#' general information sharing.
#'
#' By default, everyting but \code{expr} will be looked for in a "\code{SLACK_}"
#' environment variable. You can override or just specify these values directly instead,
#' but it's probably better to call `slackrSetup()` first.
#'
#' @param expr an R expression to be evaluated
#' @param channel which channel to post the message to (chr)
#' @param username what user should the bot be named as (chr)
#' @param icon_emoji what emoji to use (chr) \code{""} will mean use the default
#' @param slack_webhook_url_prefix which slack.com API endpoint URL to use
#' @param token your webhook API token
#' @return if there was an error posting to Slack, the \code{POST} response object will be returned
#' @import httr
#' @examples
#' \dontrun{
#' slackrSetup(channel="#code",
#'             url_prefix="http://myslack.slack.com/services/hooks/incoming-webhook?")
#' slackr(str(iris))
#' }
#' @export
slackr <- function(expr,
                   channel=Sys.getenv("SLACK_CHANNEL"),
                   username=Sys.getenv("SLACK_USERNAME"),
                   icon_emoji=Sys.getenv("SLACK_ICON_EMOJI"),
                   slack_webhook_url_prefix=Sys.getenv("SLACK_URL_PREFIX"),
                   token=Sys.getenv("SLACK_TOKEN")) {

  if (slack_webhook_url_prefix == "" | token == "") {
    stop("No URL prefix and/or token specified. Did you forget to call slackrSetup()?", call. = FALSE)
  }

  if (missing(expr)) {
    stop('"expr" must be specified', call. = FALSE)
  }

  data <- capture.output(eval(expr))
  data <- paste0(data, collapse="\n")

  output <- gsub('^\"|\"$', "", toJSON(data, simplifyVector=TRUE, flatten=TRUE, auto_unbox=TRUE))

  if (icon_emoji != "") { icon_emoji <- sprintf(', "icon_emoji": "%s"', icon_emoji)  }

  resp <- POST(url=paste0(slack_webhook_url_prefix, "token=", token),
               add_headers(`Content-Type`="application/x-www-form-urlencoded", `Accept`="*/*"),
               body=URLencode(sprintf('payload={"channel": "%s", "username": "%s", "text": "```%s```"%s}',
                                      channel, username, output, icon_emoji)))

  if (resp$status > 200) {
    message(resp$message)
    return(resp)
  }

  return(invisible())

}