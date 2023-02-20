#' Post a ggplot to a Slack channel
#'
#' Unlike the [slackr_dev()] function, this one takes a `ggplot` object,
#' eliminating the need to have a graphics device (think use in scripts).
#'
#' @importFrom rlang check_installed
#' @importFrom tools file_ext
#'
#' @param plot ggplot object to save, defaults to last plot displayed.
#' @param channels Comma-separated list of channel names or IDs where the file will be shared.
#' @param token Authentication token bearing required scopes.
#' @param file Prefix for filenames (defaults to `ggplot`).
#' @param initial_comment The message text introducing the file in specified channels.
#' @param thread_ts Provide another message's ts value to upload this file as a reply. Never use a reply's ts value; use its parent instead.
#' @param title Title of file.
#' @param \dots other arguments passed to \link[ggplot2]{ggsave}
#'
#' @return `httr` response object (invisibly)
#'
#' @examples
#' \dontrun{
#' slackr_setup()
#' ggslackr(qplot(mpg, wt, data = mtcars))
#' }
#' @export
ggslackr <- function(
  plot = ggplot2::last_plot(),
  channels = Sys.getenv("SLACK_CHANNEL"),
  token = Sys.getenv("SLACK_TOKEN"),
  file = "ggplot.png",
  initial_comment = NULL,
  thread_ts = NULL,
  title = NULL,
  ...
) {

  check_installed("ggplot2")

  ext <- paste0(".", file_ext(file))
  ftmp <- tempfile(file, fileext = ext)

  ggplot2::ggsave(
    filename = ftmp,
    plot = plot,
    ... = ...
  )

  res <- files_upload(
      file = ftmp,
      channels = channels,
      token = token,
      initial_comment = initial_comment,
      thread_ts = thread_ts,
      title = title
    )

  invisible(res)
}
