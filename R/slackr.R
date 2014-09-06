#' Setup environment variables for Slack.com API
#'
#' Initialize all the environment variables \link{slackr} will need to use to
#' work properly.
#'
#' By default, \code{slackr} will use the \code{#general} room and a username
#' of \code{slackr()} with no emoji and the default \url{slack.com} API prefix URL. You
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
#' @param incoming_url_prefix the slack.com URL prefix to use (chr) defaults to none
#' @param api_token the slack.com full API token (chr)
#' @param config_file a configuration file (DCF) - see \link{read.dcf} - format with the config values.
#' @param echo display the configuraiton variables (bool) initially \code{FALSE}
#' @note You need a \url{slack.com} account and will also need to setup an incoming webhook: \url{https://api.slack.com/}
#' @examples
#' \dontrun{
#' # reads from default file
#' slackrSetup()
#'
#' # reads from alternate config
#' slackrSetup(config_file="/path/to/my/slackrconfig)
#'
#' # the hard way
#' slackrSetup(channel="#code", token="mytoken",
#'             url_prefix="http://myslack.slack.com/services/hooks/incoming-webhook?")
#' }
#' @export
slackrSetup <- function(channel="#general", username="slackr",
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
    Sys.setenv(SLACK_INCOMING_URL_PREFIX=incoming_url_prefix)
    Sys.setenv(SLACK_API_TOKEN=api_token)

  }

  if (echo) {
    print(Sys.getenv(c("SLACK_CHANNEL", "SLACK_USERNAME",
                       "SLACK_ICON_EMOJI", "SLACK_TOKEN",
                       "SLACK_INCOMING_URL_PREFIX", "SLACK_API_TOKEN")))
  }

}

#' Output R expressions to a Slack.com channel/user
#'
#' Takes an \code{expr}, evaluates it and sends the output to a \url{slack.com}
#' chat destination. Useful for logging, messaging on long compute tasks or
#' general information sharing.
#'
#' By default, everyting but \code{expr} will be looked for in a "\code{SLACK_}"
#' environment variable. You can override or just specify these values directly instead,
#' but it's probably better to call \link{slackrSetup} first.
#'
#' @param ... expressions to be sent to Slack.com
#' @param channel which channel to post the message to (chr)
#' @param username what user should the bot be named as (chr)
#' @param icon_emoji what emoji to use (chr) \code{""} will mean use the default
#' @param incoming_webhook_url which \url{slack.com} API endpoint URL to use
#' @param token your webhook API token
#' @note You need a \url{slack.com} account and will also need to setup an incoming webhook: \url{https://api.slack.com/}
#' @import httr
#' @examples
#' \dontrun{
#' slackrSetup()
#' slackr("iris info", head(iris), str(iris))
#' }
#' @export
slackr <- function(...,
                   channel=Sys.getenv("SLACK_CHANNEL"),
                   username=Sys.getenv("SLACK_USERNAME"),
                   icon_emoji=Sys.getenv("SLACK_ICON_EMOJI"),
                   incoming_webhook_url=Sys.getenv("SLACK_INCOMING_URL_PREFIX"),
                   token=Sys.getenv("SLACK_TOKEN")) {

  if (incoming_webhook_url == "" | token == "") {
    stop("No URL prefix and/or token specified. Did you forget to call slackrSetup()?", call. = FALSE)
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

      resp <- POST(url=paste0(incoming_webhook_url, "token=", token),
                   add_headers(`Content-Type`="application/x-www-form-urlencoded", `Accept`="*/*"),
                   body=URLencode(sprintf('payload={"channel": "%s", "username": "%s", "text": "```%s```"%s}',
                                          channel, username, output, icon_emoji)))

      warn_for_status(resp)

      if (resp$status_code > 200) { print(str(expr))}

    }

  }

  return(invisible())

}

#' Post a ggplot to a \url{slack.com} channel
#'
#' need to setup a full API token (i.e. not a webhook & not OAuth) for this to work
#' @param api_token the slack.com full API token (chr)
#' @param channels list of channels to post image to
#' @param ... other arguments passed into png device
#' @export
#'
ggslackr <- function(api_token=Sys.getenv("SLACK_API_TOKEN"), channels=Sys.getenv("SLACK_CHANNEL"), ...) {
  Sys.setlocale('LC_ALL','C')
  ftmp <- tempfile("ggplot", fileext=".png")
  # ggsave(filename=ftmp, plot=plot, scale=scale, width=width, height=height, units=units, dpi=dpi, limitsize=limitsize, ...)
  print(ftmp)
  dev.copy(png, file=ftmp, ...)
  dev.off()
  print(channels)
  modchan <- slackr_chtrans(channels)
  print(modchan)
  POST(url="https://slack.com/api/files.upload",
       add_headers(`Content-Type`="multipart/form-data"),
       body=list( file=upload_file(ftmp), token=api_token, channels=modchan))
}

#' Translate vector of channel names to channel ID's for API
#'
#' Given a vector of one or more channel names, it will retrieve list of
#' active channels and try to replace channels that begin with "#" with
#' the channel ID for that channel.
#'
#' Returns the original channel list with #channels replaced with ID's.
#'
#' @param channels vector of channel names to parse
#' @param api_token the slack.com full API token (chr)
#' @export
slackr_chtrans <- function(channels, api_token=Sys.getenv("SLACK_API_TOKEN")) {
  cmatch <- grepl("^\\#", channels)
  if (any(cmatch)) {
    chanlist <- slackr_channels(api_token)
    cindex <- which(cmatch)
    channels[cindex] <- as.character(chanlist$id[cindex])
  }
  channels
}

#' Get data frame of slack.com users
#'
#' need to setup a full API token (i.e. not a webhook & not OAuth) for this to work
#' @param api_token the slack.com full API token (chr)
#' @export
slackr_users <- function(api_token=Sys.getenv("SLACK_API_TOKEN")) {

  Sys.setlocale('LC_ALL','C')
  tmp <- POST("https://slack.com/api/users.list", body=list(token=api_token))
  tmp.p <- content(tmp, as="parsed")
  rbindlist(lapply(tmp.p$members, function(x) { data.frame(id=x$id, name=x$name, real_name=x$real_name) }) )

}

#' Get data frame of slack.com channels
#'
#' need to setup a full API token (i.e. not a webhook & not OAuth) for this to work
#' @param api_token the slack.com full API token (chr)
#' @export
slackr_channels <- function(api_token=Sys.getenv("SLACK_API_TOKEN")) {

  Sys.setlocale('LC_ALL','C')
  tmp <- POST("https://slack.com/api/channels.list", body=list(token=api_token))
  tmp.p <- content(tmp, as="parsed")
  rbindlist(lapply(tmp.p$channels, function(x) { data.frame(id=x$id, name=x$name, is_member=x$is_member) }) )

}




