#' Setup environment variables for Slack API access
#'
#' Initialize all the environment variables \code{\link{slackr}} will need to use to
#' work properly.
#'
#' By default, \code{\link{slackr}} (and other functions) will use the \code{#general}
#' room and a username of \code{slackr()} with no emoji.
#'
#' If a valid file is found at the locaiton pointed to by \code{config_file}, the
#' values there will be used. The fields should be specified as such in the file:
#'
#' \preformatted{
#'  api_token: YOUR_FULL_API_TOKEN
#'  channel: #general
#'  username: slackr
#'  incoming_webhook_url: https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX
#' }
#'
#' @param channel default channel to send the output to (chr) defaults to \code{#general}
#' @param username the username output will appear from (chr) defaults to \code{slackr}
#' @param icon_emoji which emoji picture to use (chr) defaults to none (can be
#'        left blank in config file as well)
#' @param incoming_webhook_url the slack.com URL prefix to use (chr) defaults to none
#' @param api_token the Slack full API token (chr)
#' @param config_file a configuration file (DCF) - see \link{read.dcf} - format
#'        with the config values.
#' @param echo display the configuration variables (bool) initially \code{FALSE}
#' @note You need a \href{slack.com}{Slack} account and all your API URLs & tokens setup
#'       to use this package.
#' @seealso \code{\link{slackr}}, \code{\link{dev_slackr}}, \code{\link{save_slackr}},
#'          \code{\link{slackr_upload}}
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
#' slackr_setup(channel="#code",
#'             incoming_webhook_url="https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX")
#' }
#' @export
slackr_setup <- function(channel="#general",
                         username="slackr",
                         icon_emoji="",
                         incoming_webhook_url="",
                         api_token="",
                         config_file="~/.slackr",
                         echo=FALSE) {

  if (file.exists(config_file)) {

    config <- read.dcf(config_file,
                       fields=c("channel", "icon_emoji",
                                "username", "incoming_webhook_url", "api_token"))

    Sys.setenv(SLACK_CHANNEL=config[,"channel"])
    Sys.setenv(SLACK_USERNAME=config[,"username"])
    Sys.setenv(SLACK_ICON_EMOJI=config[,"icon_emoji"])
    Sys.setenv(SLACK_INCOMING_URL_PREFIX=config[,"incoming_webhook_url"])
    Sys.setenv(SLACK_API_TOKEN=config[,"api_token"])

  } else {

    Sys.setenv(SLACK_CHANNEL=channel)
    Sys.setenv(SLACK_USERNAME=username)
    Sys.setenv(SLACK_ICON_EMOJI=icon_emoji)
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
    print(toJSON(as.list(Sys.getenv(c("SLACK_CHANNEL", "SLACK_USERNAME",
                                      "SLACK_ICON_EMOJI",
                                      "SLACK_INCOMING_URL_PREFIX", "SLACK_API_TOKEN"))),
                 pretty=TRUE))
  }

}
