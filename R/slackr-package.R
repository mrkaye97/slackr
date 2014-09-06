#' A package to work with Slack.com webhook API messages
#'
#' You'll probably want to dive right into the \link{slackr} function for more information.
#'
#' @name slackr-package
#' @title slackr-package
#' @docType package
#' @author Bob Rudis (@@hrbrmstr)
#' @import httr jsonlite data.table
#' @examples
#' \dontrun{
#' slackrSetup()
#'
#' # send objects
#' slackr("iris info", head(iris), str(iris))
#'
#' # send images
#' library(ggplot2)
#' qplot(mpg, wt, data=mtcars)
#' dev.slack("#results")
#'
#'
#' }
NULL
