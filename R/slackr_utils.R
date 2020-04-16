#' Translate vector of channel names to channel ID's for API
#'
#' Given a vector of one or more channel names, it will retrieve list of
#' active channels and try to replace channels that begin with "\code{#}" or "\code{@@}"
#' with the channel ID for that channel. Also incorporates groups.
#'
#' @param channels vector of channel names to parse
#' @param api_token the Slack full API token (chr)
#' @param census An object in the format created by \code{\link{runcensus}}: if not supplied,
#' it looks for an object named \code{slackr_census} in your global environment. If none is found,
#' it performs \code{\link{runcensus}}.
#' @rdname slackr_chtrans
#' @author Quinn Weber [ctb], Bob Rudis [aut]
#' @return character vector - original channel list with \code{#} or
#'          \code{@@} channels replaced with ID's.
#' @export
slackr_chtrans <- function(channels,
                           api_token=Sys.getenv("SLACK_API_TOKEN"),
                           census=getGlobalIfMissing("slackr_census")) {

  if(is.null(census)){
    census <- runcensus(api_token)
  }

  chan   <- census$channels
  users  <- census$users
  ims    <- census$ims
  groups <- census$groups
  channels <- gsub("@", "", channels)
  channels <- gsub("#", "", channels)

  chan$full_name <- sprintf("#%s", chan$name)
  users$full_name <- sprintf("@%s", users$name)

  chan_list <- base::data.frame(id = character(0L), name = character(0), full_name = character(0))

  if (length(chan) > 0 && nrow(chan) > 0) { chan_list   <- rbind(chan_list, chan[, c("id", "name", "full_name")])  }
  if (length(users) > 0 && nrow(users) > 0) { chan_list  <- rbind(chan_list, users[, c("id", "name", "full_name")]) }
  if (length(groups) > 0 && nrow(groups) > 0) { chan_list <- rbind(chan_list, groups[, c("id", "name", "full_name")]) }

  chan_list <- dplyr::distinct(chan_list)

  chan_list <- base::data.frame(chan_list, stringsAsFactors=FALSE)
  chan_xref <- chan_list[chan_list$name %in% channels, ]

  if(!nrow(chan_xref)>0){
    all_matches <- unique(sapply(channels, agrep, x=chan_list$name))
    close_matches <- ifelse(class(all_matches) != "list" && length(all_matches) > 0,
                            paste0(chan_list[all_matches, "full_name"], collapse = ", "),
                            "None.")

    stop(paste0("Could not find \"", channels, "\" in your workspace. Close matches:  ", close_matches ))
  }

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

  tmp <- httr::POST("https://slack.com/api/users.list", body=list(token=api_token))
  httr::stop_for_status(tmp)
  okContent(tmp)
  members <- jsonlite::fromJSON(httr::content(tmp, as="text"))$members
  cols <- setdiff(colnames(members), c("profile", "real_name"))
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
  okContent(tmp)
  jsonlite::fromJSON(content(tmp, as="text"))$channels

}

#' Get a data frame of Slack groups
#'
#' @param api_token the Slackfull API token (chr)
#' @return \code{data.frame} of channels
#' @rdname slackr_groups
#' @importFrom jsonlite fromJSON
#' @importFrom httr POST stop_for_status
#' @export
slackr_groups <- function(api_token=Sys.getenv("SLACK_API_TOKEN")) {

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  tmp <- httr::POST("https://slack.com/api/groups.list", body=list(token=api_token))
  httr::stop_for_status(tmp)
  okContent(tmp)
  jsonlite::fromJSON(content(tmp, as="text"))$groups

}

#' Get a data frame of Slack IM ids
#'
#' @param api_token the Slack full API token (chr)
#' @rdname slackr_ims
#' @author Quinn Weber [aut], Bob Rudis [ctb]
#' @references \url{https://github.com/hrbrmstr/slackr/pull/13}
#' @return \code{data.frame} of im ids and user names
#' @importFrom assertthat assert_that
#' @importFrom dplyr left_join
#' @export
slackr_ims <- function(api_token=Sys.getenv("SLACK_API_TOKEN")) {

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  # tmp <- httr::GET("https://slack.com/api/users.list", query=list(token=api_token, limit = 2000))
  # The method below is supposedly deprecated
  tmp <- httr::GET("https://slack.com/api/im.list", query=list(token=api_token))
  okContent(tmp)
  ims <- jsonlite::fromJSON(httr::content(tmp, as="text"))$ims
  assert_that(!is.null(ims), msg = "Could not retrieve any IMs")
  users <- slackr_users(api_token)
  assert_that(nrow(users) > 0, msg = "Could not retrieve any uers")

  dplyr::left_join(users, ims, by="id", copy=TRUE)
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

