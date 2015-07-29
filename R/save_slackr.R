#' Save R objects to an RData file on \code{slack.com}
#'
#' \code{save_slackr} enables you upload R objects (as an R data file)
#' to \code{slack.com} and (optionally) post them to one or more channels
#' (if \code{channels} is not empty).
#'
#' @param ... objects to store in the R data file
#' @param channels slack.com channels to save to (optional)
#' @param file filename (without extension) to use
#' @param api_token full API token
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
                        api_token=Sys.getenv("SLACK_API_TOKEN")) {


  Sys.setlocale('LC_ALL','C')

  ftmp <- tempfile(file, fileext=".rda")
  save(..., file=ftmp)

  modchan <- slackrChTrans(channels)

  POST(url="https://slack.com/api/files.upload",
       add_headers(`Content-Type`="multipart/form-data"),
       body=list(file=upload_file(ftmp), filename=sprintf("%s.rda", file),
                  token=api_token, channels=modchan))

}

#' @rdname save_slackr
#' @export
save.slackr <- save_slackr