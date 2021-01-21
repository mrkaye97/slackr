#' Send the graphics contents of the current device to a Slack channel
#'
#' `dev.slackr` sends the graphics contents of the current device to the
#' specified Slack channel.
#'
#' @param channels list of channels to post image to
#' @param bot_user_oauth_token the Slack full bot user OAuth token (chr)
#' @param file prefix for filenames (defaults to `plot`)
#' @return `httr` response object from `POST` call
#' @seealso [slackrSetup()], [save.slackr()], [slackrUpload()]
#' @author Konrad Karczewski (ctb), Bob Rudis (aut)
#' @note You can pass in `as_user=TRUE` as part of the `...` parameters and the Slack API
#'       will post the message as your logged-in user account (this will override anything set in
#'       `username`).
#' @references <https://github.com/mrkaye97/slackr/pull/12/files>
#' @examples
#' \dontrun{
#' slackr_setup()
#'
#' # base
#' library(maps)
#' map("usa")
#' dev_slackr("#results", file='map')
#'
#' # base
#' barplot(VADeaths)
#' dev_slackr("@@jayjacobs")
#' }
#' @importFrom httr POST add_headers
#' @export
slackr_dev <- function(channels=Sys.getenv("SLACK_CHANNEL"),
                       bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"),
                       file="plot") {

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  ftmp <- tempfile(file, fileext=".png")
  dev.copy(png, file=ftmp)
  dev.off()

  modchan <- slackr_chtrans(channels)

  POST(url="https://slack.com/api/files.upload",
       add_headers(`Content-Type`="multipart/form-data"),
       body=list( file=upload_file(ftmp), token=bot_user_oauth_token, channels=modchan))

}
