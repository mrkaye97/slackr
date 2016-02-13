#' Send a file to Slack
#'
#' \code{slackrUpload} enables you upload files to Slack and
#' (optionally) post them to one or more channels (if \code{channels} is not empty).
#'
#' @rdname slackr_upload
#' @param filename path to file
#' @param title title on slack (optional - defaults to filename)
#' @param initial_comment comment for file on slack (optional - defaults to filename)
#' @param channels slack.com channels to save to (optional)
#' @param api_token full API token
#' @return \code{httr} response object from \code{POST} call (invisibly)
#' @author Quinn Weber [ctb], Bob Rudis [aut]
#' @references \url{https://github.com/hrbrmstr/slackr/pull/15/files}
#' @seealso \code{\link{slackr_setup}}, \code{\link{dev_slackr}}, \code{\link{save_slackr}}
#' @export
slackr_upload <- function(filename, title=basename(filename),
                          initial_comment=basename(filename),
                          channels="", api_token=Sys.getenv("SLACK_API_TOKEN")) {

  f_path <- path.expand(filename)

  if (file.exists(f_path)) {

    f_name <- basename(f_path)

    loc <- Sys.getlocale('LC_CTYPE')
    Sys.setlocale('LC_CTYPE','C')
    on.exit(Sys.setlocale("LC_CTYPE", loc))

    modchan <- slackrChTrans(channels)

    res <- POST(url="https://slack.com/api/files.upload",
         add_headers(`Content-Type`="multipart/form-data"),
         body=list( file=upload_file(f_path), filename=f_name,
                    title=title, initial_comment=initial_comment,
                    token=api_token, channels=paste(modchan, collapse=",")))

    return(invisible(res))

  }

}
