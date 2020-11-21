#' Save R objects to an RData file on Slack
#'
#' \code{save_slackr} enables you upload R objects (as an R data file)
#' to Slack and (optionally) post them to one or more channels
#' (if \code{channels} is not empty).
#'
#' @param ... objects to store in the R data file
#' @param channels Slack channels to save to (optional)
#' @param file filename (without extension) to use
#' @param bot_user_oauth_token Slack bot user OAuth token
#' @rdname save_slackr
#' @note You can pass in \code{add_user=TRUE} as part of the \code{...} parameters and the Slack API
#'       will post the message as your logged-in user account (this will override anything set in
#'       \code{username})
#' @return \code{httr} response object from \code{POST} call
#' @seealso \code{\link{slackr_setup}}, \code{\link{dev_slackr}}, \code{\link{slackr_upload}}
#' @export
#' @examples \dontrun{
#' slackr_setup()
#' save_slackr(mtcars, channels="#slackr", file="mtcars")
#' }
save_slackr <- function(..., channels="",
                        file="slackr",
                        bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {


  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  ftmp <- tempfile(file, fileext=".Rdata")
  save(..., file=ftmp)

  on.exit(unlink(ftmp), add=TRUE)

  modchan <- slackr_chtrans(channels)
  if (length(modchan) == 0) modchan <- ""

  res <-httr::POST(url="https://slack.com/api/files.upload",
                   httr::add_headers(`Content-Type`="multipart/form-data"),
                   body=list(file=httr::upload_file(ftmp),
                             filename=sprintf("%s.Rdata", file),
                             token=bot_user_oauth_token,
                             channels=modchan))

  stop_for_status(res)

  invisible(res)

}
