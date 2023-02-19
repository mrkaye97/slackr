#' Send a file to Slack
#'
#' `slackr_upload` enables you upload files to Slack and
#' (optionally) post them to one or more channels (if `channels` is not empty).
#'
#' @param filename path to file.
#' @param initial_comment The message text introducing the file in specified channels.
#' @param thread_ts Provide another message's ts value to upload this file as a reply. Never use a reply's ts value; use its parent instead.
#' @param title Title of file.
#' @param channels Comma-separated list of channel names or IDs where the file will be shared.
#' @param token Authentication token bearing required scopes.
#' @return `httr` response object from `POST` call (invisibly)
#' @author Quinn Weber (ctb), Bob Rudis (aut)
#' @references <https://github.com/mrkaye97/slackr/pull/15/files>
#' @seealso [slackr_setup()], [slackr_dev()], [slackr_save()]
#' @return `httr` response object from `POST` call (invisibly)
#' @importFrom httr add_headers upload_file
#' @export
slackr_upload <- function(
  filename,
  title = NULL,
  initial_comment = NULL,
  channels = Sys.getenv("SLACK_CHANNEL"),
  token = Sys.getenv("SLACK_TOKEN"),
  thread_ts = NULL
) {
  if (channels == "") abort("No channels specified. Did you forget select which channels to post to with the 'channels' argument?")
  f_path <- path.expand(filename)

  if (file.exists(f_path)) {
    f_name <- basename(f_path)

    res <- files_upload(
      file = f_path,
      token = token,
      channels = channels,
      title = title,
      initial_comment = initial_comment,
      thread_ts = thread_ts
    )

    return(invisible(res))
  } else {
    abort(sprintf("File [%s] not found", f_path))
  }
}
