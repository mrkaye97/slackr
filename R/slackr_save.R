#' Save R objects to an RData file on Slack
#'
#' `slackr_save` enables you upload R objects (as an R data file)
#' to Slack and (optionally) post them to one or more channels
#' (if `channels` is not empty).
#'
#' @param ... objects to store in the R data file
#' @param channels Slack channels to save to (optional)
#' @param file filename (without extension) to use
#' @param token A Slack token (either a user token or a bot user token)
#' @param bot_user_oauth_token Deprecated. A Slack bot user OAuth token
#' @param plot_text the plot text to send with the plot (defaults to "")
#' @return `httr` response object from `POST` call
#' @seealso [slackr_setup()], [slackr_dev()], [slackr_upload()]
#' @importFrom httr add_headers upload_file
#' @export
#' @examples
#' \dontrun{
#' slackr_setup()
#' slackr_save(mtcars, channels = "#slackr", file = "mtcars")
#' }
slackr_save <- function(...,
                        channels = Sys.getenv("SLACK_CHANNEL"),
                        file = "slackr",
                        token = Sys.getenv("SLACK_TOKEN"),
                        plot_text = "",
                        bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {
  token <- check_tokens(token, bot_user_oauth_token)

  if (channels == "") abort("No channels specified. Did you forget select which channels to post to with the 'channels' argument?")

  ftmp <- tempfile(file, fileext = ".Rdata")
  save(..., file = ftmp, envir = parent.frame())

  on.exit(unlink(ftmp), add = TRUE)

  res <- files_upload(
    file = ftmp,
    channel = channels,
    txt = plot_text,
    token = token,
    filename = sprintf("%s.Rdata", file)
  )

  return(invisible(res))
}
