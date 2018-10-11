#' Translate vector of channel names to channel ID's for API
#'
#' Given a vector of one or more channel names, it will retrieve list of
#' active channels and try to replace channels that begin with "\code{#}" or "\code{@@}"
#' with the channel ID for that channel. Also incorporates groups.
#'
#' @param channels vector of channel names to parse
#' @param api_token the Slack full API token (chr)
#' @rdname slackr_chtrans
#' @author Quinn Weber [ctb], Bob Rudis [aut]
#' @return character vector - original channel list with \code{#} or
#'          \code{@@} channels replaced with ID's.
#' @export
slackr_chtrans <- function(channels, api_token=Sys.getenv("SLACK_API_TOKEN")) {

  if ( !is.character(api_token) | length(api_token) > 1 ) { stop("api_token must be a character vector of length one") }

  conversations <- slackr::slackr_conversations(api_token, types='public_channel,private_channel,im,mpim')
  users <- slackr::slackr_users(api_token)

  if('is_channel' %in% colnames(conversations)){ # Depending on selected types this attribute may not be available
    conversations$name <- ifelse(conversations$is_channel==T,sprintf("#%s", conversations$name), conversations$test)
  }
  users$name <- sprintf("@%s", users$name)

  chan_list <- dplyr::select(conversations, "id", "name")
  chan_list <- rbind(chan_list, dplyr::select(users,"id", "name"))
  chan_list <- dplyr::distinct(chan_list)

  chan_list <- data.frame(chan_list, stringsAsFactors=FALSE)
  chan_xref <- chan_list[chan_list$name %in% channels,]

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

  if ( !is.character(api_token) | length(api_token) > 1 ) { stop("api_token must be a character vector of length one") }

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  tmp <- httr::POST("https://slack.com/api/users.list", body=list(token=api_token))
  httr::stop_for_status(tmp)

  res=jsonlite::fromJSON(httr::content(tmp, as="text"), flatten=T)

  members = res$members
  nextCursor=res$response_metadata$next_cursor

  while (nextCursor!="") {
    tmp <- POST("https://slack.com/api/users.list",
              body=list(token=api_token, cursor=nextCursor))
    stop_for_status(tmp)
    res=jsonlite::fromJSON(content(tmp, as="text"), flatten=T)
    members = dplyr::bind_rows(members, res$members)
    nextCursor=res$response_metadata$next_cursor
  }

  members

}


#' Get a data frame of Slack conversations
#'
#' @param api_token the Slack full API token (chr)
#' @param types Types of conversations to pull, comma separated, e.g. public_channel,im will pull public channels and direct messages. The possible values are public_channel, private_channel, im and mpim
#' @return data.table of conversations
#' @rdname slackr_conversations
#' @export
slackr_conversations <- function(api_token=Sys.getenv("SLACK_API_TOKEN"), types='public_channel') {

  if ( !is.character(api_token) | length(api_token) > 1 ) { stop("api_token must be a character vector of length one") }

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  tmp <- POST("https://slack.com/api/conversations.list",
              body=list(token=api_token, types=types, limit=1000))
  stop_for_status(tmp)
  res=jsonlite::fromJSON(content(tmp, as="text"), flatten=T)

  chanList = res$channels
  nextCursor=res$response_metadata$next_cursor

  while (nextCursor!="") {
    tmp <- POST("https://slack.com/api/conversations.list",
              body=list(token=api_token, types=types, limit=1000, cursor=nextCursor))
    stop_for_status(tmp)
    res=jsonlite::fromJSON(content(tmp, as="text"), flatten=T)
    chanList = dplyr::bind_rows(chanList, res$channels)
    nextCursor=res$response_metadata$next_cursor
  }

  chanList
}

#' Get a data frame of Slack channels
#'
#' @param api_token the Slack full API token (chr)
#' @return data.table of channels
#' @rdname slackr_channels
#' @export
slackr_channels <- function(api_token=Sys.getenv("SLACK_API_TOKEN")) {

  if ( !is.character(api_token) | length(api_token) > 1 ) { stop("api_token must be a character vector of length one") }

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

  if ( !is.character(api_token) | length(api_token) > 1 ) { stop("api_token must be a character vector of length one") }

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  tmp <- httr::POST("https://slack.com/api/groups.list", body=list(token=api_token))
  httr::stop_for_status(tmp)
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

  if ( !is.character(api_token) | length(api_token) > 1 ) { stop("api_token must be a character vector of length one") }

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  tmp <- httr::POST("https://slack.com/api/im.list", body=list(token=api_token))
  ims <- jsonlite::fromJSON(httr::content(tmp, as="text"))$ims
  users <- slackr_users(api_token)
  suppressWarnings( merge(users, ims, by.x="id", by.y='user') )
  #dplyr::left_join(users, ims, by="id", copy=TRUE)

}

# Deprecated functions ----------------------------------------------------

#' @usage NULL
#' @rdname history_slackr
#' @export
slackr_channel_history <- function(api_token = Sys.getenv("SLACK_API_TOKEN"),
                                   channel = Sys.getenv("SLACK_CHANNEL"),
                                   posted_from_time = 0L,
                                   posted_to_time = as.numeric(Sys.time()),
                                   message_count = 100L) {
  .Deprecated("history_slackr()")
  out <- tryCatch({
    chnl <- slackr_chtrans(channel)
    params <- list(token = api_token,
                   channel = chnl,
                   latest = posted_to_time,
                   oldest = posted_from_time,
                   inclusive = "true",
                   count = message_count)

    response <- httr::GET(url = "https://slack.com/api/channels.history",
                          query = params)

    jsonlite::fromJSON(httr::content(response, as = "text"))$messages
  }, error = function(e) {
    message(paste("Channel", channel, "does not exist."))
    message(e)
  })

  return(out)
}



