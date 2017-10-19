#' return message history of a slack channel. Calls the channels.history method on the Slack Web API.
#' Information on this method can be found here: \url{https://api.slack.com/methods/channels.history}
#'
#' @param count Number of messages to return, between 1 and 1000.
#' @param ... Optional arguments such as: inclusive, latest, oldest, unreads
#' @param channel The name of the channels to which the DataTable should be sent.
#'  Prepend channel names with a hashtag. Prepend private-groups with nothing.
#'  Prepend direct messages with an @@
#' @param api_token your full Slack API token
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
                          api_token=Sys.getenv("SLACK_API_TOKEN")) {

  if ( !is.character(channel) | length(channel) > 1 ) { stop("channel must be a character vector of length one") }
  if ( !is.character(api_token) | length(api_token) > 1 ) { stop("api_token must be a character vector of length one") }


  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  chnl_map <- slackr_channels(api_token = api_token)[c('id','name')]
  chnl_map$name <- sprintf('#%s',chnl_map$name)

  resp <- httr::POST(url="https://slack.com/api/channels.history",
               body=list(token=api_token,
                         channel=chnl_map$id[grepl(sprintf('^%s$',channel),chnl_map$name)],
                         count=count,
                         ...))
  warn_for_status(resp)

  slack_hist <- jsonlite::fromJSON(httr::content(resp, as="text"))$messages

  return(slack_hist)

}
