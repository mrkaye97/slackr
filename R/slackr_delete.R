#' slackr_delete
#'
#' Deletes the specified number of messages from the channel
#' @param count the number of messages to delete
#' @param channel the channel to delete from
#' @param bot_user_oauth_token the Slack bot user OAuth token
#' @importFrom httr POST
#' @export
slackr_delete <- function(count,
                          channel=Sys.getenv("SLACK_CHANNEL"),
                          bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {

  if ( !is.character(channel) | length(channel) > 1 ) { stop("channel must be a character vector of length one") }
  if ( !is.character(bot_user_oauth_token) | length(bot_user_oauth_token) > 1 ) { stop("bot_user_oauth_token must be a character vector of length one") }


  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  chnl_map <- slackr_channels(bot_user_oauth_token = bot_user_oauth_token)[c('id','name')]
  chnl_map$name <- sprintf('#%s',chnl_map$name)

  tsvec <- slackr_history(channel = channel, message_count = count)$ts

  resp <- sapply(tsvec, function(ts,token,channel) {
    resp <- POST(
      url="https://slack.com/api/chat.delete",
      body=list(
        token   = token,
        channel = channel,
        ts      = ts)
    )
    stop_for_status(resp)
    resp
  },
  token    = bot_user_oauth_token,
  channel  = slackr_chtrans(channel),
  simplify = FALSE
  )

  invisible(resp)
}
