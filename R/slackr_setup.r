#' Setup environment variables for \code{slack.com} API
#'
#' Initialize all the environment variables \code{\link{slackr}} will need to use to
#' work properly.
#'
#' By default, \code{\link{slackr}} (and other functions) will use the \code{#general} room and a username
#' of \code{slackr()} with no emoji and the default \code{slack.com} API prefix URL. You
#' still need to provide the webhook API token in \code{token} for anyting to work.
#' Failure to call this function before calling \code{slackr()} will result in a
#' message to do so.
#'
#' If a valid file is found at the locaiton pointed to by \code{config_file}, the
#' values there will be used. The fields should be specified as such in the file: \cr
#' \cr
#' \code{ token: yourTokenCode} \cr
#' \code{ channel: #general} \cr
#' \code{ username: slackr} \cr
#' \code{ icon_emoji:} \cr
#' \code{ incoming_webhook_url: https://yourgroup.slack.com/services/hooks/incoming-webhook?} \cr \cr
#' @param channel default channel to send the output to (chr) defaults to \code{#general}
#' @param username the username output will appear from (chr) defaults to \code{slackr}
#' @param icon_emoji which emoji picture to use (chr) defaults to none (can be left blank in config file as well)
#' @param token the \url{slack.com} webhook API token string (chr) defaults to none
#' @param incoming_webhook_url the slack.com URL prefix to use (chr) defaults to none
#' @param api_token the slack.com full API token (chr)
#' @param config_file a configuration file (DCF) - see \link{read.dcf} - format with the config values.
#' @param echo display the configuraiton variables (bool) initially \code{FALSE}
#' @note You need a \url{slack.com} account and will also need to setup an incoming webhook and full API tokens: \url{https://api.slack.com/}
#' @seealso \code{\link{slackr}}, \code{\link{dev.slackr}}, \code{\link{save.slackr}}, \code{\link{slackrUpload}}
#' @rdname slackr_setup
#' @examples
#' \dontrun{
#' # reads from default file (i.e. ~/.slackr)
#' slackr_setup()
#'
#' # reads from alternate config
#' slackr_setup(config_file="/path/to/my/slackrconfig)
#'
#' # the hard way
#' slackr_setup(channel="#code", token="mytoken",
#'             url_prefix="http://myslack.slack.com/services/hooks/incoming-webhook?")
#' }
#' @export
slackr_setup <- function(channel="#general", username="slackr",
                        icon_emoji="", token="", incoming_webhook_url="",
                        api_token="", config_file="~/.slackr", echo=FALSE) {

  if (file.exists(config_file)) {

    config <- read.dcf(config_file,
                       fields=c("token", "channel", "icon_emoji",
                                "username", "incoming_webhook_url", "api_token"))

    Sys.setenv(SLACK_CHANNEL=config[,"channel"])
    Sys.setenv(SLACK_USERNAME=config[,"username"])
    Sys.setenv(SLACK_ICON_EMOJI=config[,"icon_emoji"])
    Sys.setenv(SLACK_TOKEN=config[,"token"])
    Sys.setenv(SLACK_INCOMING_URL_PREFIX=config[,"incoming_webhook_url"])
    Sys.setenv(SLACK_API_TOKEN=config[,"api_token"])

  } else {

    Sys.setenv(SLACK_CHANNEL=channel)
    Sys.setenv(SLACK_USERNAME=username)
    Sys.setenv(SLACK_ICON_EMOJI=icon_emoji)
    Sys.setenv(SLACK_TOKEN=token)
    Sys.setenv(SLACK_INCOMING_URL_PREFIX=incoming_webhook_url)
    Sys.setenv(SLACK_API_TOKEN=api_token)

  }

  if (!grepl("?$", Sys.getenv("SLACK_INCOMING_URL_PREFIX"))) {
    Sys.setenv(SLACK_INCOMING_URL_PREFIX=sprintf("%s?", config[,"incoming_webhook_url"]))
  }

  if (length(Sys.getenv("SLACK_CHANNEL"))==0) {
    Sys.setenv("SLACK_CHANNEL", "#general")
  }

  if (length(Sys.getenv("SLACK_USERNAME"))==0) {
    Sys.setenv("SLACK_USERNAME", "slackr")
  }

  if (echo) {
    print(Sys.getenv(c("SLACK_CHANNEL", "SLACK_USERNAME",
                       "SLACK_ICON_EMOJI", "SLACK_TOKEN",
                       "SLACK_INCOMING_URL_PREFIX", "SLACK_API_TOKEN")))
  }

}

#' @rdname slackr_setup
#' @export
slackrSetup <- slackr_setup