#' Send the graphics contents of the current device to a Slack channel
#'
#' `slackr_dev` sends the graphics contents of the current device to the
#' specified Slack channel.
#'
#' @param channels Comma-separated list of channel names or IDs where the file will be shared.
#' @param file prefix for filenames (defaults to `plot`).
#' @param token Authentication token bearing required scopes.
#' @param initial_comment The message text introducing the file in specified channels.
#' @param thread_ts Provide another message's ts value to upload this file as a reply. Never use a reply's ts value; use its parent instead.
#' @param title Title of file.
#' @importFrom grDevices dev.copy dev.off png
#' @return `httr` response object from `POST` call
#' @seealso [slackr_setup()], [slackr_save()], [slackr_upload()]
#' @author Konrad Karczewski (ctb), Bob Rudis (aut)
#' @references <https://github.com/mrkaye97/slackr/pull/12/files>
#' @examples
#' \dontrun{
#' slackr_setup()
#'
#' # base
#' library(maps)
#' map("usa")
#' slackr_dev("#results", file = "map")
#'
#' # base
#' barplot(VADeaths)
#' slackr_dev("@@jayjacobs")
#' }
#' @export
slackr_dev <- function(
  channels = Sys.getenv("SLACK_CHANNEL"),
  token = Sys.getenv("SLACK_TOKEN"),
  file = "plot",
  initial_comment = NULL,
  title = NULL,
  thread_ts = NULL
) {
  ftmp <- tempfile(file, fileext = ".png")
  dev.copy(png, file = ftmp)
  dev.off()

  res <- files_upload(
    file = ftmp,
    channels = channels,
    initial_comment = initial_comment,
    token = token,
    thread_ts = thread_ts
  )

  return(invisible(res))
}
