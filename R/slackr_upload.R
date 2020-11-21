#' Send a file to Slack
#'
#' \code{slackr_upload} enables you upload files to Slack and
#' (optionally) post them to one or more channels (if \code{channels} is not empty).
#'
#' @rdname slackr_upload
#' @param filename path to file
#' @param title title on Slack (optional - defaults to filename)
#' @param initial_comment comment for file on slack (optional - defaults to filename)
#' @param channels Slack channels to save to (optional)
#' @param bot_user_oauth_token Slack bot user OAuth token
#' @return \code{httr} response object from \code{POST} call (invisibly)
#' @author Quinn Weber [ctb], Bob Rudis [aut]
#' @references \url{https://github.com/hrbrmstr/slackr/pull/15/files}
#' @seealso \code{\link{slackr_setup}}, \code{\link{dev_slackr}}, \code{\link{save_slackr}}
#' @export
slackr_upload <- function(filename, title=basename(filename),
                          initial_comment=basename(filename),
                          channels="", bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {

  f_path <- path.expand(filename)

  if (file.exists(f_path)) {

    f_name <- basename(f_path)

    loc <- Sys.getlocale('LC_CTYPE')
    Sys.setlocale('LC_CTYPE','C')
    on.exit(Sys.setlocale("LC_CTYPE", loc))

    modchan <- slackrChTrans(channels, bot_user_oauth_token)

    res <- httr::POST(url="https://slack.com/api/files.upload",
                      httr::add_headers(`Content-Type`="multipart/form-data"),
                      body=list( file=httr::upload_file(f_path), filename=f_name,
                                 title=title, initial_comment=initial_comment,
                                 token=bot_user_oauth_token, channels=paste(modchan, collapse=",")))

    return(invisible(res))

  } else {
    stop(sprintf("File [%s] not found", f_path), call.=FALSE)
  }

}
