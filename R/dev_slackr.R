#' Send the graphics contents of the current device to a Slack channel
#'
#' \code{dev.slackr} sends the graphics contents of the current device to the
#' specified Slack channel.
#'
#' @param channels list of channels to post image to
#' @param ... other arguments passed into png device
#' @param api_token the slack.com full API token (chr)
#' @param file prefix for filenames (defaults to \code{plot})
#' @return \code{httr} response object from \code{POST} call
#' @seealso \code{\link{slackrSetup}}, \code{\link{save.slackr}}, \code{\link{slackrUpload}}
#' @author Konrad Karczewski [ctb], Bob Rudis [aut]
#' @note You can pass in \code{add_user=TRUE} as part of the \code{...} parameters and the Slack API
#'       will post the message as your logged-in user account (this will override anything set in
#'       \code{username})
#' @references \url{https://github.com/hrbrmstr/slackr/pull/12/files}
#' @rdname dev_slackr
#' @examples
#' \dontrun{
#' slackr_setup()
#'
#' # base
#' library(maps)
#' map("usa")
#' dev_slackr("#results", filename='map')
#'
#' # base
#' barplot(VADeaths)
#' dev_slackr("@@jayjacobs")
#' }
#' @export
dev_slackr <- function(channels=Sys.getenv("SLACK_CHANNEL"), ...,
                       api_token=Sys.getenv("SLACK_API_TOKEN"),
                       file="plot") {

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  ftmp <- tempfile(file, fileext=".png")
  dev.copy(png, file=ftmp, ...)
  dev.off()

  modchan <- slackrChTrans(channels)

  POST(url="https://slack.com/api/files.upload",
       add_headers(`Content-Type`="multipart/form-data"),
       body=list( file=upload_file(ftmp), token=api_token, channels=modchan))

}
