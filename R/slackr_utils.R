#' Fetch Data from Slack API
#'
#' @param endpoint
#' @param request_body_list
#' @param result_jsonkey
#' @param bot_user_oauth_token the Slack bot OAuth token (chr)
#' @return list of \code{data.frame} of result
#' @export
slackr_fetchapi <- function(endpoint, request_keyvalue_list, result_jsonkey, paging_size=NULL, bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {
  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))


  request_keyvalue_list <- append(request_keyvalue_list, list(token=bot_user_oauth_token))
  if (!is.null(paging_size)) {
    request_keyvalue_list <- append(request_keyvalue_list, list(limit=paging_size))
  }

  results <- list()
  next_token <- NULL


  repeat {
    post_request_keyvalue_list <- append(request_keyvalue_list, list(cursor=next_token))

    response <- httr::POST(paste0("https://slack.com/api/", endpoint), body=post_request_keyvalue_list)
    httr::stop_for_status(response)
    response_body <- jsonlite::fromJSON(httr::content(response, as="text"))

    results <- append(results, list(response_body[[result_jsonkey]]))

    next_token <- response_body$response_metadata$next_cursor
    if (next_token == '') {
      break
    }

    # message("slackr_fetchapi: found more information. fetching...")
  }


  results
}

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
  if (is.null(chan) || nrow(chan) == 0) {
    stop("slackr is not seeing any channels in your workspace. Are you sure you have the right scopes enabled? See the readme for details.")
  }
  users <- slackr_ims(bot_user_oauth_token)
  if (is.null(chan) || nrow(chan) == 0) {
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
  api_members_list <- slackr_fetchapi('users.list', list(), 'members', bot_user_oauth_token)

  users = NULL

  for (api_members in api_members_list) {
    cols <- colnames(api_members)
    cols <- setdiff(cols, c("profile", "real_name"))
    members <- cbind.data.frame(api_members[,cols], api_members$profile, stringsAsFactors=FALSE)

    if (is.null(users)) {
      users <- members
    } else {
      users <- rbind(users, members)
    }
  }

  users
}


#' Internal function to warn if Slack API call is not ok.
#'
#' The function is called for the side effect of warning when the API response has errors, and is a thin wrapper around httr::stop_for_status
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
    warning(
      "The slack API returned an error: ",
      content(r)$error,
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
slackr_channels <- function(bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {
  api_conversations_list <- slackr_fetchapi('conversations.list', list(types="public_channel,private_channel"), 'channels', 1000, bot_user_oauth_token)

  channels = NULL

  for (api_conversations in api_conversations_list) {
    cols <- colnames(api_conversations)
    cols <- setdiff(cols, c("conversation_host_id", "frozen_reason", "last_read", "is_open", "priority"))
    cols <- setdiff(cols, c("topic", "purpose"))
    conversations <- cbind.data.frame(api_conversations[,cols], list(topic=api_conversations$topic), list(purpose=api_conversations$purpose), stringsAsFactors=FALSE)


    if (is.null(channels)) {
      channels <- conversations
    } else {
      channels <- rbind(channels, conversations)
    }
  }

  channels
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
  api_conversations_list <- slackr_fetchapi('conversations.list', list(types="im"), 'channels', 1000, bot_user_oauth_token)

  ims = NULL

  for (api_conversations in api_conversations_list) {
    cols <- colnames(api_conversations)
    cols <- setdiff(cols, c("conversation_host_id", "frozen_reason", "last_read", "is_open", "priority"))
    cols <- setdiff(cols, c("topic", "purpose"))
    conversations <- cbind.data.frame(api_conversations[,cols], stringsAsFactors=FALSE)


    if (is.null(ims)) {
      ims <- conversations
    } else {
      ims <- rbind(ims, conversations)
    }
  }

  users <- slackr_users(bot_user_oauth_token)

  if ((nrow(ims) == 0) | (nrow(users) == 0)) {
    stop("slackr is not seeing any users in your workspace. Are you sure you have the right scopes enabled? See the readme for details.")
  }
  dplyr::left_join(users, ims, by="id")
}

