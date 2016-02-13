#' Sends basic text to a slack channel. Calls the chat.postMessage method on the Slack Web API.
#' Information on this method can be found here: \url{https://api.slack.com/methods/chat.postMessage}
#'
#' @param text The character vector to be posted
#' @param ... Optional arguments such as: as_user, parse, unfurl_links, etc.
#' @param preformatted Should the text be sent as preformatted text. Defaults to TRUE
#' @param channel The name of the channels to which the DataTable should be sent.
#'  Prepend channel names with a hashtag. Prepend private-groups with nothing.
#'  Prepend direct messages with an @@
#' @param username what user should the bot be named as (chr)
#' @param icon_emoji what emoji to use (chr) \code{""} will mean use the default
#' @param api_token your full slack.com API token
#' @return \code{httr} response object (invislbly)
#' @author Quinn Weber [aut], Bob Rudis [ctb]
#' @note You can pass in \code{add_user=TRUE} as part of the \code{...} parameters and the Slack API
#'       will post the message as your logged-in user account (this will override anything set in
#'       \code{username})
#' @references \url{https://github.com/hrbrmstr/slackr/pull/11}
#' @seealso \url{https://api.slack.com/methods/chat.postMessage}
#' @rdname text_slackr
#' @examples
#' \dontrun{
#' slackr_setup()
#' text_slackr('hello world', as_user=TRUE)
#' }
#' @export
text_slackr <- function(text,
                        ...,
                        preformatted=TRUE,
                        channel=Sys.getenv("SLACK_CHANNEL"),
                        username=Sys.getenv("SLACK_USERNAME"),
                        icon_emoji=Sys.getenv("SLACK_ICON_EMOJI"),
                        api_token=Sys.getenv("SLACK_API_TOKEN")) {

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

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  resp <- POST(url="https://slack.com/api/chat.postMessage",
               body=list(token=api_token,
                         channel=channel,
                         username=username,
                         icon_emoji=icon_emoji,
                         text=text,
                         link_names=1,
                         ...))

  warn_for_status(resp)

  return(invisible(resp))

}
