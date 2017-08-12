#' Post a tex output to a Slack channel
#'
#' Unlike the \code{\link{dev_slackr}} function, this one takes a \code{tex} object,
#' eliminating the need write to pdf and convert to png to pass to slack.
#'
#' @param obj character object containing tex to compile
#' @param channels list of channels to post image to
#' @param ext character, type of format to return, can be tex, pdf, or any image device, Default: 'png'
#' @param path character, path to save texPreview outputs, if NULL then tempdir is used, Default: NULL
#' @param api_token the Slack full API token (chr)
#' @param ... other arguments passed to \code{\link[texPreview]{texPreview}}
#' @note You need to setup a full API token (i.e. not a webhook & not OAuth) for this to work
#'       Also, uou can pass in \code{add_user=TRUE} as part of the \code{...}
#'       parameters and the Slack API will post the message as your logged-in user
#'       account (this will override anything set in \code{username})
#' @return \code{httr} response object (invisibly)
#' @examples
#' \dontrun{
#' slackr_setup()
#' obj=xtable::xtable(mtcars)
#' tex_slackr(obj,print.xtable.opts=list(scalebox=getOption("xtable.scalebox", 0.8)))
#'
#' tex_slackr(obj,ext = 'pdf',print.xtable.opts=list(scalebox=getOption("xtable.scalebox", 0.8)))
#'
#' tex_slackr(obj,ext = 'tex',print.xtable.opts=list(scalebox=getOption("xtable.scalebox", 0.8)))
#'
#' tex_slackr(obj,path='testdir',print.xtable.opts=list(scalebox=getOption("xtable.scalebox", 0.8)))
#' }
#' @seealso
#'  \code{\link[texPreview]{texPreview}} \code{\link[xtable]{print.xtable}}
#' @importFrom texPreview texPreview
#' @export
tex_slackr <- function(obj,
                     channels=Sys.getenv("SLACK_CHANNEL"),
                     api_token=Sys.getenv("SLACK_API_TOKEN"),
                     ext='png',
                     path=NULL,
                     ...) {

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  if(!is.null(path)){
    td <- path
  }else{
    td <- file.path(tempdir(),'slack')
  }

  if(!dir.exists(td)) dir.create(td)

  texPreview::texPreview(
    obj = obj,
    stem = 'slack',
    fileDir = td,
    imgFormat = ifelse(ext=='tex','png',ext),
    ...)

  modchan <- slackr_chtrans(channels)

  res <- POST(url="https://slack.com/api/files.upload",
              add_headers(`Content-Type`="multipart/form-data"),
              body=list(file=upload_file(file.path(td,paste0('slack.',ext))),
                        token=api_token,
                        channels=modchan))

  #cleanup
  file.remove(list.files(td,pattern = 'Doc',full.names = TRUE))

  if(is.null(path)) unlink(td,recursive = TRUE)

  invisible(res)

}
