#' edit a message on a slack channel. Calls the chat.update method on the Slack Web API.
#' Information on this method can be found here: \url{https://api.slack.com/methods/chat.update}
#'
#' @param text The character vector to be posted
#' @param pattern Filter messages by regex (grepl), Default: NULL
#' @param idx Index of message to edit (descending order), Default: 1
#' @param hs History of slack channel (if NULL a request to slacka api will be made), Default=NULL
#' @param ... Optional arguments such as: as_user, parse, unfurl_links, etc.
#' @param preformatted Should the text be sent as preformatted text. Defaults to TRUE
#' @param channel The name of the channels to which the DataTable should be sent.
#'  Prepend channel names with a hashtag. Prepend private-groups with nothing.
#'  Prepend direct messages with an @@
#' @param username what user should the bot be named as (chr)
#' @param icon_emoji what emoji to use (chr) \code{""} will mean use the default
#' @param api_token your full Slack API token
#' @param set_locale text encoding value. Default: 'C'
#' @return \code{httr} response object (invislbly)
#' @author Jonathan Sidi [aut]
#' @note You can pass in \code{add_user=TRUE} as part of the \code{...} parameters and the Slack API
#'       will post the message as your logged-in user account (this will override anything set in
#'       \code{username})
#' @seealso \url{https://api.slack.com/methods/chat.update}
#' @rdname edit_slackr
#' @examples
#' \dontrun{
#' slackr_setup()
#'
#' text_slackr('hello world')
#' text_slackr('hello new world')
#'
#' edit_slackr('another new world')
#' edit_slackr('goodbye new world',pattern='world',idx=2)
#'
#' }
#' @export
edit_slackr <- function(text,
                        pattern=NULL,
                        idx=1,
                        hs=NULL,
                        ...,
                        preformatted=TRUE,
                        channel=Sys.getenv("SLACK_CHANNEL"),
                        username=Sys.getenv("SLACK_USERNAME"),
                        icon_emoji=Sys.getenv("SLACK_ICON_EMOJI"),
                        api_token=Sys.getenv("SLACK_API_TOKEN"),
                        set.locale="C") {

  if ( length(text) > 1 ) { stop("text must be a vector of length one") }
  if ( !is.character(channel) | length(channel) > 1 ) { stop("channel must be a character vector of length one") }
  if ( !is.logical(preformatted) | length(preformatted) > 1 ) { stop("preformatted must be a logical vector of length one") }
  if ( !is.character(username) | length(username) > 1 ) { stop("username must be a character vector of length one") }
  if ( !is.character(api_token) | length(api_token) > 1 ) { stop("api_token must be a character vector of length one") }

  text <- as.character(text)

  if ( preformatted ) {
    if ( substr(text, 1, 3) != '```' ) { text <- paste0('```', text) }
    if ( substr(text, nchar(text)-2, nchar(text)) != '```' ) { text <- paste0(text, '```') }
  }

  chnl_map <- slackr_channels(api_token = api_token)[c('id','name')]
  chnl_map$name <- sprintf('#%s',chnl_map$name)

  if(is.null(hs)) hs <- history_slackr(count = 100, api_token=api_token)

  if(!is.null(pattern)) hs <- hs[grepl(pattern,hs$text),]

  if(nrow(hs)==0){
    message('Pattern: ',pattern,' returned nothing')
    return(NULL)
  }

  ts <- hs$ts[idx]

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE', set.locale)
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  resp <- POST(url="https://slack.com/api/chat.update",
               body=list(token=api_token,
                         channel=chnl_map$id[grepl(sprintf('^%s$',channel),chnl_map$name)],
                         username=username,
                         text=text,
                         link_names=1,
                         ts=ts,
                         ...))

  warn_for_status(resp)

  return(invisible(resp))

}
