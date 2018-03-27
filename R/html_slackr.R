#' Post an htmlwidget to a Slack channel
#'
#' Unlike the \code{\link{dev_slackr}} function, this one takes an \code{htmlwidget} object,
#' allowing the user to post a static image of an htmlwidget to a slack channel.
#'
#' @param plot htmlwidget object to save, defaults to last item ouptut
#' @param channels list of channels to post image to
#' @param api_token the Slack full API token (chr)
#' @param file prefix for filenames (defaults to \code{widget})
#' @param ... other arguments passed to graphics device
#' @note You need to setup a full API token (i.e. not a webhook & not OAuth) for this to work
#'       Also, uou can pass in \code{as_user=TRUE} as part of the \code{...}
#'       parameters and the Slack API will post the message as your logged-in user
#'       account (this will override anything set in \code{username})
#' @return \code{httr} response object (invisibly)
#' @examples
#' \dontrun{
#' slackr_setup()
#' htmlslackr(DT::datatable(iris))
#' }
#' @export

htmlslackr <- function(plot,
                     channels = Sys.getenv("SLACK_CHANNEL"),
                     api_token = Sys.getenv("SLACK_API_TOKEN"),
                     file = "widget",
                     ...) {
  if (missing(plot)) {plot <- .Last.value}
  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))
  ftmp <- tempfile(file,fileext = ".html")
  ftmp2 <- tempfile(file,fileext = ".png")

  if (any(class(plot) %in% c("htmlwidget"))) {
    htmlwidgets::saveWidget(plot,ftmp)
  } else {
    stop("This function is only formatted for htmlwidgets")
  }

  webshot::webshot(ftmp,ftmp2)
  modchan <- slackr_chtrans(channels)

  res <- httr::POST(url = "https://slack.com/api/files.upload",
              httr::add_headers(`Content-Type` = "multipart/form-data"),
              body = list(file = httr::upload_file(ftmp2),
                        token = api_token,
                        channels = modchan))
  unlink(c(ftmp,ftmp2))
  return(invisible(res))
}
