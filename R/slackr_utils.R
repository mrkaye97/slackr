#' Translate vector of channel names to channel ID's for API
#'
#' Given a vector of one or more channel names, it will retrieve list of
#' active channels and try to replace channels that begin with "\code{#}" or "\code{@@}"
#' with the channel ID for that channel. Also incorporates groups.
#'
#' @param channels vector of channel names to parse
#' @param api_token the slack.com full API token (chr)
#' @rdname slackr_chtrans
#' @author Quinn Weber [ctb], Bob Rudis [aut]
#' @return character vector - original channel list with \code{#} or
#'          \code{@@} channels replaced with ID's.
#' @export
slackr_chtrans <- function(channels, api_token=Sys.getenv("SLACK_API_TOKEN")) {

  chan <- slackr_channels(api_token)
  users <- slackr_ims(api_token)
  groups <- slackr_groups(api_token)

  chan$name <- sprintf("#%s", chan$name)
  users$name <- sprintf("@%s", users$name)

  chan_list <- data_frame(id=character(0), name=character(0))

  if (length(chan) > 0) { chan_list <- bind_rows(chan_list, chan[, c("id", "name")])  }
  if (length(users) > 0) { chan_list <- bind_rows(chan_list, users[, c("id", "name")]) }
  if (length(groups) > 0) { chan_list <- bind_rows(chan_list, groups[, c("id", "name")]) }

  chan_list <- data.frame(chan_list, stringsAsFactors=FALSE)
  chan_xref <- chan_list[chan_list$name %in% channels, ]

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
  members <- jsonlite::fromJSON(content(tmp, as="text"))$members
  cols <- setdiff(colnames(members), "profile")
  cbind.data.frame(members[,cols], members$profile, stringsAsFactors=FALSE)

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
  jsonlite::fromJSON(content(tmp, as="text"))$channels

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
  tmp_p <- jsonlite::fromJSON(content(tmp, as="text"))$groups

}

#' @rdname slackr_groups
#' @export
slackrGroups <- slackr_groups

#' Get a data frame of slack.com IM ids
#'
#' need to setup a full API token (i.e. not a webhook & not OAuth) for this to work
#'
#' @param api_token the slack.com full API token (chr)
#' @rdname slackr_ims
#' @author Quinn Weber [aut], Bob Rudis [ctb]
#' @references \url{https://github.com/hrbrmstr/slackr/pull/13}
#' @return data.table of im ids and user names
#' @export
slackr_ims <- function(api_token=Sys.getenv("SLACK_API_TOKEN")) {

  Sys.setlocale('LC_ALL','C')

  tmp <- POST("https://slack.com/api/im.list", body=list(token=api_token))
  ims <- jsonlite::fromJSON(content(tmp, as="text"))$ims
  users <- slackr_users(api_token)
  left_join(users, ims, by="id")

}

#' @rdname slackr_ims
#' @export
slackrIms <- slackr_ims
