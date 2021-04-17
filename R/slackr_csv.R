#' Send a data frame to Slack as a CSV
#'
#' `slackr_csv` simplifies the process of sending a data frame to Slack as a CSV file.
#' It is highly recommended to leave the `filename` argument as the default (tempfile), as changing it will persist a csv file in your working directory.
#'
#' @importFrom utils write.csv
#' @param data the data frame to upload
#' @param filename the file to save to. Defaults to a tempfile. Using the default is _highly_ advised, as using a non-tempfile will write a file that persists on the disk (either in the working directory, or at the location specified)
#' @param channels Slack channels to save to (optional)
#' @param title title on Slack (optional - defaults to filename)
#' @param initial_comment comment for file on slack (optional - defaults to filename)
#' @param bot_user_oauth_token Slack bot user OAuth token
#' @param ... additional arguments to be passed to `write.csv()`
#' @return `httr` response object from `POST` call (invisibly)
#' @author Matt Kaye (aut)
#' @seealso [slackr_upload()]
#' @return `httr` response object from `POST` call (invisibly)
#' @export
slackr_csv <- function(data,
                       filename = tempfile(fileext = ".csv"),
                       title = basename(filename),
                       initial_comment = basename(filename),
                       channels = Sys.getenv("SLACK_CHANNEL"),
                       bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"),
                       ...) {
  write.csv(data, filename, ...)

  res <- slackr_upload(
    filename = filename,
    title = title,
    initial_comment = initial_comment,
    channels = channels,
    bot_user_oauth_token = bot_user_oauth_token
  )

  return(invisible(res))
}
