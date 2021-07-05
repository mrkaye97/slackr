#' Send a file to Slack
#'
#' `slackr_upload` enables you upload files to Slack and
#' (optionally) post them to one or more channels (if `channels` is not empty).
#'
#' @param filename path to file
#' @param title title on Slack (optional - defaults to filename)
#' @param initial_comment comment for file on slack (optional - defaults to filename)
#' @param channels Slack channels to save to (optional)
#' @param token A Slack token (either a user token or a bot user token)
#' @param bot_user_oauth_token Deprecated. A Slack bot user OAuth token
#' @return `httr` response object from `POST` call (invisibly)
#' @author Quinn Weber (ctb), Bob Rudis (aut)
#' @references <https://github.com/mrkaye97/slackr/pull/15/files>
#' @seealso [slackr_setup()], [slackr_dev()], [slackr_save()]
#' @return `httr` response object from `POST` call (invisibly)
#' @importFrom httr add_headers upload_file
#' @export
slackr_upload <- function(filename, title = basename(filename),
                          initial_comment = basename(filename),
                          channels = Sys.getenv("SLACK_CHANNEL"),
                          token = Sys.getenv("SLACK_TOKEN"),
                          bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {
  token <- check_tokens(token, bot_user_oauth_token)

  if (channels == "") abort("No channels specified. Did you forget select which channels to post to with the 'channels' argument?")
  f_path <- path.expand(filename)

  if (file.exists(f_path)) {
    f_name <- basename(f_path)

    res <- POST(
      url = "https://slack.com/api/files.upload",
      add_headers(`Content-Type` = "multipart/form-data"),
      body = list(
        file = upload_file(f_path), filename = f_name,
        title = title, initial_comment = initial_comment,
        token = token, channels = paste(channels, collapse = ",")
      )
    )

    if (!content(res)$ok) abort(content(res)$error, " -- Are you sure you used the right token and channel name?")

    return(invisible(res))
  } else {
    abort(sprintf("File [%s] not found", f_path))
  }
}
