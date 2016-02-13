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

  chan_list <- dplyr::distinct(chan_list)

  chan_list <- data.frame(chan_list, stringsAsFactors=FALSE)
  chan_xref <- chan_list[chan_list$name %in% channels, ]

  ifelse(is.na(chan_xref$id),
         as.character(chan_xref$name),
         as.character(chan_xref$id))

}


#' Get a data frame of Slack users
#'
#' @param api_token the Slack full API token (chr)
#' @return \code{data.frame} of users
#' @rdname slackr_users
#' @export
slackr_users <- function(api_token=Sys.getenv("SLACK_API_TOKEN")) {

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  tmp <- POST("https://slack.com/api/users.list",
              body=list(token=api_token))
  stop_for_status(tmp)
  members <- jsonlite::fromJSON(content(tmp, as="text"))$members
  cols <- setdiff(colnames(members), "profile")
  cbind.data.frame(members[,cols], members$profile, stringsAsFactors=FALSE)

}

#' Get a data frame of Slack channels
#'
#' @param api_token the Slack full API token (chr)
#' @return data.table of channels
#' @rdname slackr_channels
#' @export
slackr_channels <- function(api_token=Sys.getenv("SLACK_API_TOKEN")) {

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  tmp <- POST("https://slack.com/api/channels.list",
              body=list(token=api_token))
  stop_for_status(tmp)
  jsonlite::fromJSON(content(tmp, as="text"))$channels

}

#' Get a data frame of Slack groups
#'
#' @param api_token the Slackfull API token (chr)
#' @return \code{data.frame} of channels
#' @rdname slackr_groups
#' @export
slackr_groups <- function(api_token=Sys.getenv("SLACK_API_TOKEN")) {

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  tmp <- POST("https://slack.com/api/groups.list",
              body=list(token=api_token))
  stop_for_status(tmp)
  jsonlite::fromJSON(content(tmp, as="text"))$groups

}

#' Get a data frame of Slack IM ids
#'
#' @param api_token the Slack full API token (chr)
#' @rdname slackr_ims
#' @author Quinn Weber [aut], Bob Rudis [ctb]
#' @references \url{https://github.com/hrbrmstr/slackr/pull/13}
#' @return \code{data.frame} of im ids and user names
#' @export
slackr_ims <- function(api_token=Sys.getenv("SLACK_API_TOKEN")) {

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  tmp <- POST("https://slack.com/api/im.list", body=list(token=api_token))
  ims <- jsonlite::fromJSON(content(tmp, as="text"))$ims
  users <- slackr_users(api_token)
  dplyr::left_join(users, ims, by="id")

}
