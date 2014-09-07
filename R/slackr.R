#' Setup environment variables for \code{slack.com} API
#'
#' Initialize all the environment variables \link{slackr} will need to use to
#' work properly.
#'
#' By default, \code{slackr} (and other functions) will use the \code{#general} room and a username
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
#' @param incoming_webhook_url the slack.com URL prefix to use (chr) defaults to none
#' @param api_token the slack.com full API token (chr)
#' @param config_file a configuration file (DCF) - see \link{read.dcf} - format with the config values.
#' @param echo display the configuraiton variables (bool) initially \code{FALSE}
#' @note You need a \url{slack.com} account and will also need to setup an incoming webhook and full API tokens: \url{https://api.slack.com/}
#' @seealso \code{\link{slackr}}, \code{\link{dev.slackr}}, \code{\link{save.slackr}}, \code{\link{slackrUpload}}
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
    Sys.setenv(SLACK_INCOMING_URL_PREFIX=incoming_webhook_url)
    Sys.setenv(SLACK_API_TOKEN=api_token)

  }

  if (echo) {
    print(Sys.getenv(c("SLACK_CHANNEL", "SLACK_USERNAME",
                       "SLACK_ICON_EMOJI", "SLACK_TOKEN",
                       "SLACK_INCOMING_URL_PREFIX", "SLACK_API_TOKEN")))
  }

}

#' Output R expressions to a \code{slack.com} channel/user (as \code{slackbot})
#'
#' Takes an \code{expr}, evaluates it and sends the output to a \url{slack.com}
#' chat destination. Useful for logging, messaging on long compute tasks or
#' general information sharing.
#'
#' By default, everyting but \code{expr} will be looked for in a "\code{SLACK_}"
#' environment variable. You can override or just specify these values directly instead,
#' but it's probably better to call \link{slackrSetup} first.
#'
#' This function uses the incoming webhook API and posts user messages as \code{slackbot}
#'
#' @param ... expressions to be sent to Slack.com
#' @param channel which channel to post the message to (chr)
#' @param username what user should the bot be named as (chr)
#' @param icon_emoji what emoji to use (chr) \code{""} will mean use the default
#' @param incoming_webhook_url which \url{slack.com} API endpoint URL to use
#' @param token your webhook API token
#' @note You need a \url{slack.com} account and will also need to setup an incoming webhook: \url{https://api.slack.com/}
#' @seealso \code{\link{slackrSetup}}, \code{\link{slackr}}, \code{\link{dev.slackr}}, \code{\link{save.slackr}}, \code{\link{slackrUpload}}
#' @examples
#' \dontrun{
#' slackrSetup()
#' slackr("iris info", head(iris), str(iris))
#' }
#' @export
slackrBot <- function(...,
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


#' Output R expressions to a \code{slack.com} channel/user
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
#' @param api_token your full slack.com API token
#' @note You need a \url{slack.com} account and will also need to setup an API token \url{https://api.slack.com/}
#' @seealso \code{\link{slackrSetup}}, \code{\link{slackrBot}}, \code{\link{dev.slackr}}, \code{\link{save.slackr}}, \code{\link{slackrUpload}}
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
                   api_token=Sys.getenv("SLACK_API_TOKEN")) {

  if (api_token == "") {
    stop("No token specified. Did you forget to call slackrSetup()?", call. = FALSE)
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

      output <- data

      resp <- POST(url="https://slack.com/api/chat.postMessage",
                   body=list(token=api_token, channel=channel,
                             username=username, icon_emoji=icon_emoji,
                             text=sprintf("```%s```", output), link_names=1))

      warn_for_status(resp)

      if (resp$status_code > 200) { print(str(expr))}

    }

  }

  return(invisible())

}

#' Send the graphics contents of the current device to a \code{slack.com} channel
#'
#' \code{dev.slackr} sends the graphics contents of the current device to the specified \code{slack.com} channel.
#' This requires setting up a full API token (i.e. not a webhook & not OAuth) for this to work.
#'
#' @param channels list of channels to post image to
#' @param ... other arguments passed into png device
#' @param api_token the slack.com full API token (chr)
#' @return \code{httr} response object from \code{POST} call
#' @seealso \code{\link{slackrSetup}}, \code{\link{save.slackr}}, \code{\link{slackrUpload}}
#' @examples
#' \dontrun{
#' slackrSetup()
#'
#' # ggplot
#' library(ggplot2)
#' qplot(mpg, wt, data=mtcars)
#' dev.slackr("#results")
#'
#' # base
#' barplot(VADeaths)
#' dev.slackr("@@jayjacobs")
#' }
#' @export
dev.slackr <- function(channels=Sys.getenv("SLACK_CHANNEL"), ...,
                       api_token=Sys.getenv("SLACK_API_TOKEN")) {

  Sys.setlocale('LC_ALL','C')

  ftmp <- tempfile("plot", fileext=".png")
  dev.copy(png, file=ftmp, ...)
  dev.off()

  modchan <- slackrChTrans(channels)

  POST(url="https://slack.com/api/files.upload",
       add_headers(`Content-Type`="multipart/form-data"),
       body=list( file=upload_file(ftmp), token=api_token, channels=modchan))

}

#' Post a ggplot to a \url{slack.com} channel
#'
#' Unlike the \code{\link{dev.slackr}} function, this one takes a \code{ggplot} object,
#' eliminating the need to have a graphics device (think use in scripts).
#'
#' @param plot ggplot object to save, defaults to last plot displayed
#' @param channels list of channels to post image to
#' @param scale scaling factor
#' @param width width (defaults to the width of current plotting window)
#' @param height height (defaults to the height of current plotting window)
#' @param units units for width and height when either one is explicitly specified (in, cm, or mm)
#' @param dpi dpi to use for raster graphics
#' @param limitsize when TRUE (the default), ggsave will not save images larger than 50x50 inches, to prevent the common error of specifying dimensions in pixels.
#' @param api_token the slack.com full API token (chr)
#' @param ... other arguments passed to graphics device
#' @note You need to setup a full API token (i.e. not a webhook & not OAuth) for this to work
#' @return \code{httr} response object
#' @examples
#' \dontrun{
#' slackrSetup()
#' ggslackr(qplot(mpg, wt, data=mtcars))
#' }
#' @export
ggslackr <- function(plot=last_plot(), channels=Sys.getenv("SLACK_CHANNEL"), scale=1, width=par("din")[1], height=par("din")[2],
                     units=c("in", "cm", "mm"), dpi=300, limitsize=TRUE, api_token=Sys.getenv("SLACK_API_TOKEN"), ...) {

  Sys.setlocale('LC_ALL','C')
  ftmp <- tempfile("ggplot", fileext=".png")
  ggsave(filename=ftmp, plot=plot, scale=scale, width=width, height=height, units=units, dpi=dpi, limitsize=limitsize, ...)

  modchan <- slackrChTrans(channels)

  POST(url="https://slack.com/api/files.upload",
       add_headers(`Content-Type`="multipart/form-data"),
       body=list( file=upload_file(ftmp), token=api_token, channels=modchan))

}


#' Save R objects to an RData file on \code{slack.com}
#'
#' \code{save.slackr} enables you upload R objects (as an R data file)
#' to \code{slack.com} and (optionally) post them to one or more channels
#' (if \code{channels} is not empty).
#'
#' @param ... objects to store in the R data file
#' @param channels slack.com channels to save to (optional)
#' @param file filename (without extension) to use
#' @param api_token full API token
#' @return \code{httr} response object from \code{POST} call
#' @seealso \code{\link{slackrSetup}}, \code{\link{dev.slackr}}, \code{\link{slackrUpload}}
#' @export
save.slackr <- function(..., channels="",
                        file="slackr",
                        api_token=Sys.getenv("SLACK_API_TOKEN")) {


  Sys.setlocale('LC_ALL','C')

  ftmp <- tempfile(file, fileext=".rda")
  save(..., file=ftmp)

  modchan <- slackrChTrans(channels)

  POST(url="https://slack.com/api/files.upload",
       add_headers(`Content-Type`="multipart/form-data"),
       body=list(file=upload_file(ftmp), filename=sprintf("%s.rda", file),
                  token=api_token, channels=modchan))

}

#' Send a file to \code{slack.com}
#'
#' \code{slackrUoload} enables you upload files to \code{slack.com} and
#' (optionally) post them to one or more channels (if \code{channels} is not empty).
#'
#' @param filename path to file
#' @param title title on slack (optional - defaults to filename)
#' @param initial_comment comment for file on slack (optional - defaults to filename)
#' @param channels slack.com channels to save to (optional)
#' @param api_token full API token
#' @return \code{httr} response object from \code{POST} call
#' @seealso \code{\link{slackrSetup}}, \code{\link{dev.slackr}}, \code{\link{save.slackr}}
#' @export
slackrUpload <- function(filename, title=basename(filename),
                         initial_comment=basename(filename),
                         channels="", api_token=Sys.getenv("SLACK_API_TOKEN")) {

  f_path <- path.expand(filename)

  if (file.exists(f_path)) {

    f_name <- basename(f_path)

    Sys.setlocale('LC_ALL','C')

    modchan <- slackrChTrans(channels)

    POST(url="https://slack.com/api/files.upload",
         add_headers(`Content-Type`="multipart/form-data"),
         body=list( file=upload_file(f_path), filename=f_name,
                    title=title, initial_comment=initial_comment,
                    token=api_token, channels=modchan))

  }

}

#' Translate vector of channel names to channel ID's for API
#'
#' Given a vector of one or more channel names, it will retrieve list of
#' active channels and try to replace channels that begin with "\code{#}" or "\code{@@}"
#' with the channel ID for that channel. Also incorporates groups.
#'
#' @param channels vector of channel names to parse
#' @param api_token the slack.com full API token (chr)
#' @note Renamed from \code{slackr_chtrans}
#' @return character vector - original channel list with \code{#} or \code{@@} channels replaced with ID's.
#' @export
slackrChTrans <- function(channels, api_token=Sys.getenv("SLACK_API_TOKEN")) {

  chan <- slackrChannels(api_token)
  users <- slackrUsers(api_token)
  groups <- slackrGroups(api_token)

  chan$name <- sprintf("#%s", chan$name)
  users$name <- sprintf("@%s", users$name)

  chan_list <- rbind(chan[,1:2,with=FALSE],
                     users[,1:2,with=FALSE],
                     groups[,1:2,with=FALSE])

  chan_xref <- merge(data.frame(name=channels), chan_list, all.x=TRUE)

  ifelse(is.na(chan_xref$id),
         as.character(chan_xref$name),
         as.character(chan_xref$id))

}

#' Get a data frame of slack.com users
#'
#' need to setup a full API token (i.e. not a webhook & not OAuth) for this to work
#'
#' @param api_token the slack.com full API token (chr)
#' @return data.table of users
#' @export
slackrUsers <- function(api_token=Sys.getenv("SLACK_API_TOKEN")) {

  Sys.setlocale('LC_ALL','C')
  tmp <- POST("https://slack.com/api/users.list", body=list(token=api_token))
  tmp_p <- content(tmp, as="parsed")
  rbindlist(lapply(tmp_p$members, function(x) {
    data.frame(id=x$id, name=x$name, real_name=x$real_name)
  }) )

}

#' Get a data frame of slack.com channels
#'
#' need to setup a full API token (i.e. not a webhook & not OAuth) for this to work
#'
#' @param api_token the slack.com full API token (chr)
#' @return data.table of channels
#' @note Renamed from \code{slackr_channels}
#' @export
slackrChannels <- function(api_token=Sys.getenv("SLACK_API_TOKEN")) {

  Sys.setlocale('LC_ALL','C')
  tmp <- POST("https://slack.com/api/channels.list", body=list(token=api_token))
  tmp_p <- content(tmp, as="parsed")
  rbindlist(lapply(tmp_p$channels, function(x) {
    data.frame(id=x$id, name=x$name, is_member=x$is_member)
  }) )

}

#' Get a data frame of slack.com groups
#'
#' need to setup a full API token (i.e. not a webhook & not OAuth) for this to work
#'
#' @param api_token the slack.com full API token (chr)
#' @return data.table of channels
#' @export
slackrGroups <- function(api_token=Sys.getenv("SLACK_API_TOKEN")) {

  Sys.setlocale('LC_ALL','C')
  tmp <- POST("https://slack.com/api/groups.list", body=list(token=api_token))
  tmp_p <- content(tmp, as="parsed")
  rbindlist(lapply(tmp_p$groups, function(x) {
    data.frame(id=x$id, name=x$name, is_archived=x$is_archived)
  }) )

}

