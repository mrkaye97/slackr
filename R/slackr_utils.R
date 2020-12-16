#' Translate vector of channel names to channel ID's for API
#'
#' Given a vector of one or more channel names, it will retrieve list of
#' active channels and try to replace channels that begin with "\code{#}" or "\code{@@}"
#' with the channel ID for that channel.
#'
#' @param channels vector of channel names to parse
#' @param bot_user_oauth_token the Slack bot user OAuth token (chr)
#' @rdname slackr_chtrans
#' @author Quinn Weber [ctb], Bob Rudis [aut]
#' @return character vector - original channel list with \code{#} or
#'          \code{@@} channels replaced with ID's.
#' @import dplyr
#' @export
slackr_chtrans <- function(channels, bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {
  if (!file.exists(".channel_cache")) {
    channel_cache <- slackr_census()
  } else {
    channel_cache <- read.csv('.channel_cache', sep=',')
  }

  chan_xref <- channel_cache[(channel_cache$name %in% channels ) | (channel_cache$real_name %in% channels), ]

  ifelse(is.na(chan_xref$id),
         as.character(chan_xref$name),
         as.character(chan_xref$id))
}

#' Create a cache of the users and channels in the workspace in order to limit API requests
#'
#' @param bot_user_oauth_token the Slack bot OAuth token (chr)
#' @return A data.frame of channels and users
#' @rdname slackr_census
#'
slackr_census <- function(bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {
  chan <- slackr_channels(bot_user_oauth_token)
  if (nrow(chan) == 0) {
    stop("slackr is not seeing any channels in your workspace. Are you sure you have the right scopes enabled? See the readme for details.")
  }
  users <- slackr_ims(bot_user_oauth_token)
  if (nrow(chan) == 0) {
    stop("slackr is not seeing any users in your workspace. Are you sure you have the right scopes enabled? See the readme for details.")
  }
  chan$name <- sprintf("#%s", chan$name)
  users$name <- sprintf("@%s", users$name)

  chan_list <- data.frame(id=character(0), name=character(0), real_name=character(0))

  if (length(chan) > 0) { chan_list <- dplyr::bind_rows(chan_list, chan[, c("id", "name")])  }
  if (length(users) > 0) { chan_list <- dplyr::bind_rows(chan_list, users[, c("id", "name", "real_name")]) }

  chan_list <- dplyr::distinct(chan_list)

  chan_list <- data.frame(chan_list, stringsAsFactors=FALSE)

  return(chan_list)
}

#' Create a cache of the users and channels in the workspace in order to limit API requests
#'
#' @param bot_user_oauth_token the Slack bot OAuth token (chr)
#' @return NULL
#' @rdname slackr_createcache
#'
slackr_createcache <- function(bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {
  census <- slackr_census(bot_user_oauth_token)
  write.table(census, file = '.channel_cache', sep = ',', row.names = FALSE, append = FALSE)

  return("Channel cache located in working directory, named .channel_cache")
}

#' Get a data frame of Slack users
#'
#' @param bot_user_oauth_token the Slack bot OAuth token (chr)
#' @return \code{data.frame} of users
#' @rdname slackr_users
#' @export
slackr_users <- function(bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  tmp <- httr::POST("https://slack.com/api/users.list", body=list(token=bot_user_oauth_token))
  httr::stop_for_status(tmp)
  members <- jsonlite::fromJSON(httr::content(tmp, as="text"))$members
  cols <- setdiff(colnames(members), c("profile", "real_name"))
  cbind.data.frame(members[,cols], members$profile, stringsAsFactors=FALSE)

}

#' Get a data frame of Slack channels
#'
#' @param bot_user_oauth_token the Slack bot OAuth token (chr)
#' @return data.table of channels
#' @rdname slackr_channels
#' @export
slackr_channels <- function(bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  tmp <- POST("https://slack.com/api/conversations.list?limit=500&types=public_channel,private_channel",
              body=list(token=bot_user_oauth_token))
  stop_for_status(tmp)
  jsonlite::fromJSON(content(tmp, as="text"))$channels

}

#' Get a data frame of Slack IM ids
#'
#' @param bot_user_oauth_token the Slack both OAuth token (chr)
#' @rdname slackr_ims
#' @author Quinn Weber [aut], Bob Rudis [ctb]
#' @references \url{https://github.com/hrbrmstr/slackr/pull/13}
#' @return \code{data.frame} of im ids and user names
#' @export
slackr_ims <- function(bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  tmp <- httr::POST("https://slack.com/api/conversations.list?types=im", body=list(token=bot_user_oauth_token))
  ims <- jsonlite::fromJSON(httr::content(tmp, as="text"))$channels
  users <- slackr_users(bot_user_oauth_token)

  if ((nrow(ims) == 0) | (nrow(users) == 0)) {
    stop("slackr is not seeing any users in your workspace. Are you sure you have the right scopes enabled? See the readme for details.")
  }
  dplyr::left_join(users, ims, by="id")
}
