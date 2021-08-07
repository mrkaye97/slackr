#' Save R objects to an RData file on Slack
#'
#' `slackr_save` enables you upload R objects (as an R data file)
#' to Slack and (optionally) post them to one or more channels
#' (if `channels` is not empty).
#'
#' @param ... objects to store in the R data file.
#' @param channels Comma-separated list of channel names or IDs where the file will be shared.
#' @param file filename (without extension) to use.
#' @param token Authentication token bearing required scopes.
#' @param initial_comment The message text introducing the file in specified channels.
#' @param thread_ts Provide another message's ts value to upload this file as a reply. Never use a reply's ts value; use its parent instead.
#' @param title Title of file.
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
                        initial_comment = NULL,
                        title = NULL,
                        thread_ts = NULL) {
  if (channels == "") abort("No channels specified. Did you forget select which channels to post to with the 'channels' argument?")

  ftmp <- tempfile(file, fileext = ".Rdata")
  save(..., file = ftmp, envir = parent.frame())

  on.exit(unlink(ftmp), add = TRUE)

  res <- files_upload(
    file = ftmp,
    channels = channels,
    txt = initial_comment,
    token = token,
    filename = sprintf("%s.Rdata", file),
    title = title,
    thread_ts = thread_ts
  )

  return(invisible(res))
}
