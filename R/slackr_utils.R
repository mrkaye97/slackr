#' Translate vector of channel names to channel ID's for API
#'
#' Given a vector of one or more channel names, it will retrieve list of
#' active channels and try to replace channels that begin with "\code{#}" or "\code{@@}"
#' with the channel ID for that channel. Also incorporates groups.
#'
#' @param channels vector of channel names to parse
#' @param api_token the slack.com full API token (chr)
#' @rdname slackr_chtrans
#' @return character vector - original channel list with \code{#} or \code{@@} channels replaced with ID's.
#' @export
slackr_chtrans <- function(channels, api_token=Sys.getenv("SLACK_API_TOKEN")) {

  chan <- slackrChannels(api_token)
  users <- slackrUsers(api_token)
  groups <- slackrGroups(api_token)

  chan$name <- sprintf("#%s", chan$name)
  users$name <- sprintf("@%s", users$name)

  chan_list <- data.table(id=character(0), name=character(0))

  if (length(chan) > 0) { chan_list <- rbind(chan_list, chan[,1:2,with=FALSE])  }
  if (length(users) > 0) { chan_list <- rbind(chan_list, users[,1:2,with=FALSE]) }
  if (length(groups) > 0) { chan_list <- rbind(chan_list, groups[,1:2,with=FALSE]) }

  chan_xref <- merge(data.frame(name=channels), chan_list, all.x=TRUE)

  ifelse(is.na(chan_xref$id),
         as.character(chan_xref$name),
         as.character(chan_xref$id))

}

#' @rdname slackr_chtrans
#' @export
slackrChTrans <- slackr_chtrans

#' Get a data frame of slack.com users
#'
#' need to setup a full API token (i.e. not a webhook & not OAuth) for this to work
#'
#' @param api_token the slack.com full API token (chr)
#' @return data.table of users
#' @rdname slackr_users
#' @export
slackr_users <- function(api_token=Sys.getenv("SLACK_API_TOKEN")) {

  Sys.setlocale('LC_ALL','C')
  tmp <- POST("https://slack.com/api/users.list", body=list(token=api_token))
  tmp_p <- content(tmp, as="parsed")
  rbindlist(lapply(tmp_p$members, function(x) {
    if ( is.null(x$real_name) ) { x$real_name <- "" }
    data.frame(id=nax(x$id), name=nax(x$name), real_name=nax(x$real_name))
  }) )

}

#' @rdname slackr_users
#' @export
slackrUsers <- slackr_users

#' Get a data frame of slack.com channels
#'
#' need to setup a full API token (i.e. not a webhook & not OAuth) for this to work
#'
#' @param api_token the slack.com full API token (chr)
#' @return data.table of channels
#' @note Renamed from \code{slackr_channels}
#' @rdname slackr_channels
#' @export
slackr_channels <- function(api_token=Sys.getenv("SLACK_API_TOKEN")) {

  Sys.setlocale('LC_ALL','C')
  tmp <- POST("https://slack.com/api/channels.list", body=list(token=api_token))
  tmp_p <- content(tmp, as="parsed")
  rbindlist(lapply(tmp_p$channels, function(x) {
    data.frame(id=nax(x$id), name=nax(x$name), is_member=nax(x$is_member))
  }) )

}

#' @rdname slackr_channels
#' @export
slackrChannels <- slackr_channels

#' Get a data frame of slack.com groups
#'
#' need to setup a full API token (i.e. not a webhook & not OAuth) for this to work
#'
#' @param api_token the slack.com full API token (chr)
#' @return data.table of channels
#' @rdname slackr_groups
#' @export
slackr_groups <- function(api_token=Sys.getenv("SLACK_API_TOKEN")) {

  Sys.setlocale('LC_ALL','C')
  tmp <- POST("https://slack.com/api/groups.list", body=list(token=api_token))
  tmp_p <- content(tmp, as="parsed")
  rbindlist(lapply(tmp_p$groups, function(x) {
    data.frame(id=nax(x$id), name=nax(x$name), is_archived=nax(x$is_archived))
  }) )

}

#' @rdname slackr_groups
#' @export
slackrGroups <- slackr_groups

# helper function for NULLs as return value
nax <- function(x) {
  ifelse(is.null(x), NA, x)
}
