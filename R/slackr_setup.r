#' Setup environment variables for Slack API access
#'
#' Initialize all the environment variables [slackr()] will need to use to
#' work properly.
#'
#' By default, [slackr()] (and other functions) will use the `#general`
#' room and a username of `slackr()` with no emoji.
#'
#' If a valid file is found at the locaiton pointed to by `config_file`, the
#' values there will be used. The fields should be specified as such in the file:
#'
#' \preformatted{
#'  bot_user_oauth_token: SLACK_BOT_USER_OAUTH_TOKEN
#'  channel: #general
#'  username: slackr
#'  incoming_webhook_url: https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX
#' }
#'
#' @param channel default channel to send the output to (chr) defaults to `#general`
#' @param username the username output will appear from (chr) defaults to `slackr`
#' @param icon_emoji which emoji picture to use (chr) defaults to none (can be
#'        left blank in config file as well)
#' @param incoming_webhook_url the Slack URL prefix to use (chr) defaults to none
#' @param bot_user_oauth_token the Slack full bot user OAuth token (chr)
#' @param config_file a configuration file (DCF) - see [read.dcf] - format
#'        with the config values.
#' @param echo display the configuration variables (bool) initially `FALSE`
#' @param cacheChannels a boolean for whether or not you want to cache channels to limit API requests (deprecated)
#' @param cache_dir the location for an on-disk cache. defaults to an in-memory cache if no location is specified
#' @importFrom jsonlite toJSON
#' @return "Successfully connected to Slack"
#' @note You need a [Slack](https://slack.com) account and all your API URLs & tokens setup
#'       to use this package.
#' @seealso [slackr()], [dev_slackr()], [save_slackr()],
#'          [slackr_upload()]
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
                         bot_user_oauth_token="",
                         config_file="~/.slackr",
                         echo=FALSE,
                         cacheChannels = TRUE,
                         cache_dir = '') {

  if (!missing(cacheChannels)) {
    warning('cacheChannels parameter is deprecated as of slackr 2.1.0. channels are now auto-cached with memoization')
  }

  Sys.setenv(SLACK_CACHE_DIR = cache_dir)

  if (file.exists(config_file)) {

    config <- read.dcf(
      config_file,
      fields=c("channel", "icon_emoji",
               "username", "incoming_webhook_url", "bot_user_oauth_token")
      )

    Sys.setenv(SLACK_CHANNEL=config[,"channel"])
    Sys.setenv(SLACK_USERNAME=config[,"username"])
    Sys.setenv(SLACK_ICON_EMOJI=config[,"icon_emoji"])
    Sys.setenv(SLACK_INCOMING_URL_PREFIX=config[,"incoming_webhook_url"])
    Sys.setenv(SLACK_BOT_USER_OAUTH_TOKEN=config[,"bot_user_oauth_token"])

  } else {
    if (bot_user_oauth_token == '') {
      stop("No config file found. Please specify your Slack bot OAuth token\n   with the bot_user_oauth_token argument in slackr_setup().")
    }
    Sys.setenv(SLACK_CHANNEL=channel)
    Sys.setenv(SLACK_USERNAME=username)
    Sys.setenv(SLACK_ICON_EMOJI=icon_emoji)
    Sys.setenv(SLACK_INCOMING_URL_PREFIX=incoming_webhook_url)
    Sys.setenv(SLACK_BOT_USER_OAUTH_TOKEN=bot_user_oauth_token)

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
    print(toJSON(as.list(
      Sys.getenv(c("SLACK_CHANNEL", "SLACK_USERNAME",
                   "SLACK_ICON_EMOJI",
                   "SLACK_INCOMING_URL_PREFIX", "SLACK_BOT_USER_OAUTH_TOKEN")
      )),
      pretty=TRUE))
  }

  msg <- 'Successfully connected to Slack'
  return(msg)
}
