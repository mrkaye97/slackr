#' delete messages of a slack channel. Calls the chat.delete method on the Slack Web API.
#' Information on this method can be found here: \url{https://api.slack.com/methods/chat.delete}
#'
#' @param count Number of messages to delete.
#' @param channel The name of the channels to which the DataTable should be sent.
#'  Prepend channel names with a hashtag. Prepend private-groups with nothing.
#'  Prepend direct messages with an @@
#' @param api_token your full Slack API token
#' @return \code{httr} response object (invislbly)
#' @author Quinn Weber [aut], Bob Rudis [ctb]
#' @seealso \url{https://api.slack.com/methods/chat.delete}
#' @rdname delete_slackr
#' @examples
#' \dontrun{
#' slackr_setup()
#' delete_slackr(count=1)
#' }
#' @export
delete_slackr <- function(count,
                           channel=Sys.getenv("SLACK_CHANNEL"),
                           api_token=Sys.getenv("SLACK_API_TOKEN")) {

  if ( !is.character(channel) | length(channel) > 1 ) { stop("channel must be a character vector of length one") }
  if ( !is.character(api_token) | length(api_token) > 1 ) { stop("api_token must be a character vector of length one") }


  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  chnl_map <- slackr_channels(api_token = api_token)[c('id','name')]
  chnl_map$name <- sprintf('#%s',chnl_map$name)

  tsvec <- history_slackr(count=count)$ts

  resp <- sapply(tsvec, function(ts,token,channel){
    resp <- httr::POST(url="https://slack.com/api/chat.delete",
               body=list(token=token,
                         channel=channel,
                         ts=ts))
    warn_for_status(resp)

    return(resp)
  },
  token=api_token,
  channel=chnl_map$id[grepl(sprintf('^%s$',channel),chnl_map$name)],simplify = FALSE
  )

  return(invisible(resp))

}
