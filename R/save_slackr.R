#' Save R objects to an RData file on Slack
#'
#' `save_slackr` enables you upload R objects (as an R data file)
#' to Slack and (optionally) post them to one or more channels
#' (if `channels` is not empty).
#'
#' @param ... objects to store in the R data file
#' @param channels Slack channels to save to (optional)
#' @param file filename (without extension) to use
#' @param bot_user_oauth_token Slack bot user OAuth token
#' @param plot_text the plot text to send with the plot (defaults to "")
#' @return `httr` response object from `POST` call
#' @seealso [slackr_setup()], [slackr_dev()], [slackr_upload()]
#' @importFrom httr add_headers upload_file
#' @export
#' @examples \dontrun{
#' slackr_setup()
#' save_slackr(mtcars, channels="#slackr", file="mtcars")
#' }
save_slackr <- function(...,
                        channels=Sys.getenv("SLACK_CHANNEL"),
                        file="slackr",
                        bot_user_oauth_token=Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"),
                        plot_text = '') {

  if (channels == '') stop("No channels specified. Did you forget select which channels to post to with the 'channels' argument?")

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  ftmp <- tempfile(file, fileext=".Rdata")
  save(..., file=ftmp)

  on.exit(unlink(ftmp), add=TRUE)

  res <- files_upload(
    file = ftmp,
    channel = channels,
    txt = plot_text,
    bot_user_oauth_token = bot_user_oauth_token,
    filename = sprintf("%s.Rdata", file)
  )

  stop_for_status(res)

  return(invisible(res))
}
