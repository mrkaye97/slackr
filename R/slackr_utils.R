#' Translate vector of channel names to channel IDs for API
#'
#' Given a vector of one or more channel names, retrieve list of
#' active channels and try to replace channels that begin with "`#`" or "`@@`"
#' with the channel ID for that channel.
#'
#' @param channels vector of channel names to parse
#' @author Quinn Weber (ctb), Bob Rudis (aut)
#' @return character vector - original channel list with `#` or
#'          `@@` channels replaced with ID's.
#' @importFrom R.cache loadCache
#' @export
slackr_chtrans <- function(channels) {
  channel_cache <- loadCache(key = list('channel_cache'))

  if (is.null(channel_cache)) {
    channel_cache <- slackr_census()
  }

  chan_xref <-
    channel_cache[(channel_cache$name        %in% channels) |
                    (channel_cache$real_name %in% channels) |
                    (channel_cache$id        %in% channels), ]

  ifelse(
    is.na(chan_xref$id),
    as.character(chan_xref$name),
    as.character(chan_xref$id)
  )
}

#' Create a cache of the users and channels in the workspace in order to limit API requests
#'
#' @param bot_user_oauth_token the Slack bot OAuth token (chr)
#' @return A data.frame of channels and users
#' @importFrom dplyr bind_rows distinct
#' @importFrom tibble tibble
#'
slackr_census <- function(bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {

  msg <- "Are you sure you have the right scopes enabled? See the readme for details."

  chan <- slackr_channels(bot_user_oauth_token)
  if (is.null(chan) || nrow(chan) == 0) {
    stop("slackr is not seeing any channels in your workspace. ", msg)
  }

  users <- slackr_ims(bot_user_oauth_token)
  if (is.null(chan) || nrow(chan) == 0) {
    stop("slackr is not seeing any users in your workspace. ", msg)
  }

  chan$name <- sprintf("#%s", chan$name)
  users$name <- sprintf("@%s", users$name)

  chan_list <- tibble(
    id        = character(0),
    name      = character(0),
    real_name = character(0)
  )

  if (length(chan) > 0) {
    chan_list <- bind_rows(chan_list, chan[, c("id", "name")])
  }
  if (length(users) > 0) {
    chan_list <- bind_rows(chan_list, users[, c("id", "name", "real_name")])
  }

  distinct(chan_list)
}

#' Create a cache of the users and channels in the workspace in order to limit API requests
#'
#' @return the memoized census function
#' @importFrom R.cache saveCache
#'
slackr_createcache <- function() {
  channel_cache <- slackr_census()
  saveCache(channel_cache, key = list('channel_cache'))

  message('Cache created')
  invisible(NULL)
}


#' Get a data frame of Slack users
#'
#' @param bot_user_oauth_token the Slack bot OAuth token (chr)
#' @return `data.frame` of users
#' @importFrom dplyr bind_cols setdiff
#' @export
slackr_users <- function(bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {

  members <- list_users()
  cols <- setdiff(colnames(members), c("profile", "real_name"))
  bind_cols(
    members[, cols],
    members$profile
  )

}



#' Get a data frame of Slack channels
#'
#' @param bot_user_oauth_token the Slack bot OAuth token (chr)
#' @param verbose If TRUE, prints progress messages.
#' @importFrom dplyr bind_rows
#' @return data.table of channels
#' @export
slackr_channels <- function(bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"), verbose = interactive()) {

  if (verbose) {
    message("Reading public channels list")
  }
  c1 <- list_channels(bot_user_oauth_token = bot_user_oauth_token, types = "public_channel")

  if (verbose) {
    message("Reading private channels list")
  }
  c2 <- list_channels(bot_user_oauth_token = bot_user_oauth_token, types = "private_channel")

  bind_rows(c1, c2)

}

#' Get a data frame of Slack IM ids
#'
#' @param bot_user_oauth_token the Slack both OAuth token (chr)
#' @param verbose If TRUE, prints progress messages
#' @importFrom dplyr left_join
#'
#' @author Quinn Weber (aut), Bob Rudis (ctb)
#' @references <https://github.com/mrkaye97/slackr/pull/13>
#' @return `data.frame` of im ids and user names
#' @export
slackr_ims <- function(bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"), verbose = interactive()) {

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  if (verbose) {
    message("Reading im channels list")
  }
  ims <- list_channels(bot_user_oauth_token = bot_user_oauth_token, types = "im")

  if (verbose) {
    message("Reading users list")
  }
  users <- slackr_users(bot_user_oauth_token = bot_user_oauth_token)

  if ((nrow(ims) == 0) | (nrow(users) == 0)) {
    stop("slackr is not seeing any users in your workspace. Are you sure you have the right scopes enabled? See the readme for details.")
  }
  left_join(users, ims, by="id")
}
