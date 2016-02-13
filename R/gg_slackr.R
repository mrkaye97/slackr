#' Post a ggplot to a Slack channel
#'
#' Unlike the \code{\link{dev_slackr}} function, this one takes a \code{ggplot} object,
#' eliminating the need to have a graphics device (think use in scripts).
#'
#' @param plot ggplot object to save, defaults to last plot displayed
#' @param channels list of channels to post image to
#' @param scale scaling factor
#' @param width width (defaults to the width of current plotting window)
#' @param height height (defaults to the height of current plotting window)
#' @param units units for width and height when either one is explicitly specified
#'        (in, cm, or mm)
#' @param dpi dpi to use for raster graphics
#' @param limitsize when TRUE (the default), ggsave will not save images larger
#'        than 50x50 inches, to prevent the common error of specifying dimensions in pixels.
#' @param api_token the slack.com full API token (chr)
#' @param file prefix for filenames (defaults to \code{ggplot})
#' @param ... other arguments passed to graphics device
#' @note You need to setup a full API token (i.e. not a webhook & not OAuth) for this to work
#'       Also, uou can pass in \code{add_user=TRUE} as part of the \code{...}
#'       parameters and the Slack API will post the message as your logged-in user
#'       account (this will override anything set in \code{username})
#' @return \code{httr} response object (invisibly)
#' @examples
#' \dontrun{
#' slackr_setup()
#' ggslackr(qplot(mpg, wt, data=mtcars))
#' }
#' @export
ggslackr <- function(plot=last_plot(),
                     channels=Sys.getenv("SLACK_CHANNEL"),
                     scale=1,
                     width=par("din")[1],
                     height=par("din")[2],
                     units=c("in", "cm", "mm"),
                     dpi=300,
                     limitsize=TRUE,
                     api_token=Sys.getenv("SLACK_API_TOKEN"),
                     file="ggplot",
                     ...) {

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  ftmp <- tempfile(file, fileext=".png")
  ggsave(filename=ftmp,
         plot=plot,
         scale=scale,
         width=width,
         height=height,
         units=units,
         dpi=dpi,
         limitsize=limitsize, ...)

  modchan <- slackr_chtrans(channels)

  res <- POST(url="https://slack.com/api/files.upload",
              add_headers(`Content-Type`="multipart/form-data"),
              body=list(file=upload_file(ftmp),
                        token=api_token,
                        channels=modchan))

  invisible(res)

}
