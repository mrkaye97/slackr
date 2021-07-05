#' Send the graphics contents of the current device to a Slack channel
#'
#' `slackr_dev` sends the graphics contents of the current device to the
#' specified Slack channel.
#'
#' @param channels list of channels to post image to
#' @param token A Slack token (either a user token or a bot user token)
#' @param bot_user_oauth_token Deprecated. A Slack bot user OAuth token
#' @param file prefix for filenames (defaults to `plot`)
#' @param plot_text the plot text to send with the plot (defaults to "")
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
slackr_dev <- function(channels = Sys.getenv("SLACK_CHANNEL"),
                       token = Sys.getenv("SLACK_TOKEN"),
                       plot_text = "",
                       file = "plot",
                       bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {
  token <- check_tokens(token, bot_user_oauth_token)

  ftmp <- tempfile(file, fileext = ".png")
  dev.copy(png, file = ftmp)
  dev.off()

  res <- files_upload(
    file = ftmp,
    channel = channels,
    txt = plot_text,
    token = token
  )

  return(invisible(res))
}
