#' Translate vector of channel names to channel ID's for API
#'
#' Given a vector of one or more channel names, it will retrieve list of
#' active channels and try to replace channels that begin with "`#`" or "`@@`"
#' with the channel ID for that channel.
#'
#' @param channels vector of channel names to parse
#' @param bot_user_oauth_token the Slack bot user OAuth token (chr)
#' @rdname slackr_chtrans
#' @author Quinn Weber (ctb), Bob Rudis (aut)
#' @return character vector - original channel list with `#` or
#'          `@@` channels replaced with ID's.
#' @import dplyr
#' @export
slackr_chtrans <- function(channels, bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {
  if (!file.exists(".channel_cache")) {
    channel_cache <- slackr_census()
  } else {
    channel_cache <- read.csv('.channel_cache', sep=',')
  }

  chan_xref <-
    channel_cache[(channel_cache$name        %in% channels ) |
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
#' @rdname slackr_census
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
    chan_list <- dplyr::bind_rows(chan_list, chan[, c("id", "name")])
  }
  if (length(users) > 0) {
    chan_list <- dplyr::bind_rows(chan_list, users[, c("id", "name", "real_name")])
  }

  dplyr::distinct(chan_list)
}

#' Create a cache of the users and channels in the workspace in order to limit API requests
#'
#' @param bot_user_oauth_token the Slack bot OAuth token (chr)
#' @return NULL
#' @rdname slackr_createcache
#'
slackr_createcache <- function(bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {
  census <- slackr_census(bot_user_oauth_token)
  file_name <- '.channel_cache'
  write.table(
    census,
    file = file_name,
    sep = ',',
    row.names = FALSE,
    append = FALSE
  )

  message("Channel cache located in working directory, named .channel_cache")
  invisible(normalizePath(file_name))
}


#' Get a data frame of Slack users
#'
#' @param bot_user_oauth_token the Slack bot OAuth token (chr)
#' @return `data.frame` of users
#' @rdname slackr_users
#' @export
slackr_users <- function(bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {

  members <- list_users()
  cols <- setdiff(colnames(members), c("profile", "real_name"))
  bind_cols(
    members[, cols],
    members$profile
  )

}


#' Internal function to warn if Slack API call is not ok.
#'
#' The function is called for the side effect of warning when the API response
#' has errors, and is a thin wrapper around httr::stop_for_status
#'
#' @param r The response from a call to the Slack API
#'
#' @return NULL
#' @importFrom httr status_code content
#' @keywords Internal
#' @noRd
#'
stop_for_status <- function(r) {
  # note that httr::stop_for_status should be called explicitly
  httr::stop_for_status(r)
  cr <- content(r)

  # A response code of 200 doesn't mean everything is ok, so check if the
  # response is not ok
  if (status_code(r) == 200 && !is.null(cr$ok) && !cr$ok) {
    error_msg <- cr$error
    cr$ok <- NULL
    cr$error <- NULL
    additional_msg <- paste(
      sapply(seq_along(cr), function(i)paste(names(cr)[i], ":=", unname(cr)[i])),
      collapse = "\n"
    )
    warning(
      "\n",
      "The slack API returned an error: ", error_msg, "\n",
      additional_msg,
      call. = FALSE,
      immediate. = TRUE
    )
  }
  invisible(NULL)
}


#' Get a data frame of Slack channels
#'
#' @param bot_user_oauth_token the Slack bot OAuth token (chr)
#' @return data.table of channels
#' @rdname slackr_channels
#' @export
slackr_channels <- function(bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {

  message("Reading public channels list")
  c1 <- list_channels(bot_user_oauth_token = bot_user_oauth_token, types = "public_channel")

  message("Reading private channels list")
  c2 <- list_channels(bot_user_oauth_token = bot_user_oauth_token, types = "private_channel")

  bind_rows(c1, c2)

}

#' Get a data frame of Slack IM ids
#'
#' @param bot_user_oauth_token the Slack both OAuth token (chr)
#' @rdname slackr_ims
#' @author Quinn Weber (aut), Bob Rudis (ctb)
#' @references <https://github.com/mrkaye97/slackr/pull/13>
#' @return `data.frame` of im ids and user names
#' @export
slackr_ims <- function(bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  message("Reading im channels list")
  ims <- list_channels(bot_user_oauth_token = bot_user_oauth_token, types = "im")

  message("Reading users list")
  users <- slackr_users(bot_user_oauth_token = bot_user_oauth_token)

  if ((nrow(ims) == 0) | (nrow(users) == 0)) {
    stop("slackr is not seeing any users in your workspace. Are you sure you have the right scopes enabled? See the readme for details.")
  }
  dplyr::left_join(users, ims, by="id")
}
