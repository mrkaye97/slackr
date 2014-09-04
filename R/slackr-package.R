#' A package to send webhook API messages to Slack.com channels/users
#'
#' @name slackr
#' @docType package
#' @author Bob Rudis (@@hrbrmstr)
#' @import httr jsonlite
#' @examples
#' \dontrun{
#' slackrSetup(channel="#code", url_prefix="http://myslack.slack.com/services/hooks/incoming-webhook?")
#' slackr(str(iris))
#' }
NULL
