#' Send a data frame to Slack as a CSV
#'
#' `slackr_csv` simplifies the process of sending a data frame to Slack as a CSV file.
#' It is highly recommended to leave the `filename` argument as the default (tempfile), as changing it will persist a csv file in your working directory.
#'
#' @importFrom utils write.csv
#' @param data the data frame or tibble to upload.
#' @param filename the file to save to. Defaults to a tempfile. Using the default is _highly_ advised, as using a non-tempfile will write a file that persists on the disk (either in the working directory, or at the location specified).
#' @param channels Comma-separated list of channel names or IDs where the file will be shared.
#' @param title Title of file.
#' @param initial_comment The message text introducing the file in specified channels.
#' @param token Authentication token bearing required scopes.
#' @param thread_ts Provide another message's ts value to upload this file as a reply. Never use a reply's ts value; use its parent instead.
#' @param ... additional arguments to be passed to `write.csv()`.
#' @return `httr` response object from `POST` call (invisibly)
#' @author Matt Kaye (aut)
#' @seealso [slackr_upload()]
#' @return `httr` response object from `POST` call (invisibly)
#' @export
slackr_csv <- function(
  data,
  filename = tempfile(fileext = ".csv"),
  title = NULL,
  initial_comment = NULL,
  channels = Sys.getenv("SLACK_CHANNEL"),
  token = Sys.getenv("SLACK_TOKEN"),
  thread_ts = NULL,
  ...
) {
  write.csv(data, filename, ...)

  res <- files_upload(
    file = filename,
    title = title,
    initial_comment = initial_comment,
    channels = channels,
    token = token,
    thread_ts = thread_ts
  )

  return(invisible(res))
}
