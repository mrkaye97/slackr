#' Post a tex output to a Slack channel
#'
#' Unlike the [slackr_dev()] function, this one takes a `tex` object,
#' eliminating the need write to pdf and convert to png to pass to slack.
#'
#' @param obj character object containing tex to compile.
#' @param channels Comma-separated list of channel names or IDs where the file will be shared.
#' @param ext character, type of format to return, can be tex, pdf, or any image device, Default: 'png'.
#' @param path character, path to save tex_preview outputs, if NULL then tempdir is used, Default: NULL.
#' @param token Authentication token bearing required scopes.
#' @param initial_comment The message text introducing the file in specified channels.
#' @param thread_ts Provide another message's ts value to upload this file as a reply. Never use a reply's ts value; use its parent instead.
#' @param title Title of file.
#' @param ... other arguments passed to [texPreview::tex_preview()], see Details
#' @note You need to setup a full API token (i.e. not a webhook & not OAuth) for this to work
#'       Also, you can pass in `add_user=TRUE` as part of the `...`
#'       parameters and the Slack API will post the message as your logged-in user
#'       account (this will override anything set in `username`)
#' @return `httr` response object (invisibly)
#' @details Please make sure `texPreview` package is installed before running this function.
#'          For TeX setup refer to the
#'          [Setup notes on `LaTeX`](https://github.com/mrkaye97/slackr#latex-for-slackr_tex).
#' @seealso
#'  [texPreview::tex_preview()]
#' @author Jonathan Sidi (aut)
#' @export
slackr_tex <- function(obj,
                       channels = Sys.getenv("SLACK_CHANNEL"),
                       token = Sys.getenv("SLACK_TOKEN"),
                       ext = "png",
                       path = NULL,
                       title = NULL,
                       initial_comment = NULL,
                       thread_ts = NULL,
                       ...) {

  # check if texPreview is installed, if not provide feedback
  check_tex_pkg()

  if (!is.null(path)) {
    td <- path
  } else {
    td <- file.path(tempdir(), "slack")
  }

  if (!dir.exists(td)) dir.create(td)

  texPreview::tex_preview(
    obj = obj,
    stem = "slack",
    fileDir = td,
    imgFormat = ifelse(ext == "tex", "png", ext),
    ...
  )

  res <- files_upload(
    file = td,
    channels = channels,
    token = token,
    title = title,
    initial_comment = initial_comment,
    thread_ts = thread_ts
  )

  # cleanup
  file.remove(list.files(td, pattern = "Doc", full.names = TRUE))

  if (is.null(path)) unlink(td, recursive = TRUE)

  invisible(res)
}



#' check_tex_pkg
#'
#' Check if texPreview is intalled
#' @description Install or load texPreview package,
#'   inspired by the `parsnip` package
#' @noRd
#'
check_tex_pkg <- function() {
  is_installed <- try(
    suppressPackageStartupMessages(
      requireNamespace("texPreview", quietly = TRUE)
    ),
    silent = TRUE
  )

  if (!is_installed) {
    abort("texPreview package is not installed, run ?slackr_tex and see Details.")
  }
}
