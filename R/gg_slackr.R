#' Post a ggplot to a Slack channel
#'
#' Unlike the [slackr_dev()] function, this one takes a `ggplot` object,
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
#' @param token A Slack token (either a user token or a bot user token)
#' @param bot_user_oauth_token Deprecated. A Slack bot user OAuth token
#' @param file prefix for filenames (defaults to `ggplot`)
#' @param ... other arguments passed to graphics device
#' @importFrom ggplot2 ggsave last_plot ggplot aes geom_point
#' @importFrom graphics par
#' @return `httr` response object (invisibly)
#' @examples
#' \dontrun{
#' slackr_setup()
#' ggslackr(qplot(mpg, wt, data = mtcars))
#' }
#' @export
ggslackr <- function(plot = last_plot(),
                     channels = Sys.getenv("SLACK_CHANNEL"),
                     scale = 1,
                     width = par("din")[1],
                     height = par("din")[2],
                     units = NULL,
                     dpi = 300,
                     limitsize = TRUE,
                     token = Sys.getenv("SLACK_TOKEN"),
                     file = "ggplot",
                     bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"),
                     ...) {

  token <- check_tokens(token, bot_user_oauth_token)

  ftmp <- tempfile(file, fileext = ".png")
  ggsave(
    filename = ftmp,
    plot = plot,
    scale = scale,
    width = width,
    height = height,
    units = units,
    dpi = dpi,
    limitsize = limitsize,
    ... = ...
  )

  res <-
    files_upload(
      file = ftmp,
      channel = channels,
      token = token
    )

  invisible(res)
}
