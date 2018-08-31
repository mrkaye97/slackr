#' return message history of a slack channel. Calls the channels.history method on the Slack Web API.
#' Information on this method can be found here: \url{https://api.slack.com/methods/channels.history}
#'
#' @param count Number of messages to return, between 1 and 1000.
#' @param ... Optional arguments such as: inclusive, latest, oldest, unreads
#' @param channel The name of the channels to which the DataTable should be sent.
#'  Prepend channel names with a hashtag. Prepend private-groups with nothing.
#'  Prepend direct messages with an @@
#' @param api_token your full Slack API token
#' @param include_private Include private channels in this
#' @return \code{httr} response object (invislbly)
#' @author Jonathan Sidi [aut]
#' @seealso \url{https://api.slack.com/methods/channels.history}
#' @rdname history_slackr
#' @examples
#' \dontrun{
#' slackr_setup()
#' history_slackr(count=1)
#' }
#' @export
history_slackr <- function(count,
                           ...,
                           channel=Sys.getenv("SLACK_CHANNEL"),
                           api_token=Sys.getenv("SLACK_API_TOKEN"),
                           include_private = TRUE) {

  if ( !is.character(channel) | length(channel) > 1 ) { stop("channel must be a character vector of length one") }
  if ( !is.character(api_token) | length(api_token) > 1 ) { stop("api_token must be a character vector of length one") }


  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  # for private channels
  chnl_map <- slackr_channels(api_token = api_token)[c('id','name')]
  if (nrow(chnl_map) > 0) {
    chnl_map$public <- TRUE
  }
  if (include_private) {
    private_chnl_map <- slackr_groups(api_token = api_token)[c('id','name')]
    if (nrow(private_chnl_map) > 0) {
      private_chnl_map$public <- FALSE
    }
    chnl_map = bind_rows(private_chnl_map, chnl_map)
  }

  # in case you forgot your #
  if (!grepl("^#", channel)) {
    channel = paste0("#", channel)
  }

  chnl_map$name <- sprintf('#%s',chnl_map$name)
  channel_df = chnl_map[grepl(sprintf('^%s$',channel),chnl_map$name),]
  channel_id = channel_df$id
  public = channel_df$public
  endpoint = ifelse(public, "channels.history", "groups.history")

  resp <- httr::POST(url= paste0("https://slack.com/api/", endpoint),
                     body=list(token = api_token,
                               channel = channel_id,
                               count=count,
                               ...))
  warn_for_status(resp)

  slack_hist <- jsonlite::fromJSON(httr::content(resp, as="text"))$messages

  return(slack_hist)

}
