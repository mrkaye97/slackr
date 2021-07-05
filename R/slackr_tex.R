#' Post a tex output to a Slack channel
#'
#' Unlike the [slackr_dev()] function, this one takes a `tex` object,
#' eliminating the need write to pdf and convert to png to pass to slack.
#'
#' @param obj character object containing tex to compile
#' @param channels list of channels to post image to
#' @param ext character, type of format to return, can be tex, pdf, or any image device, Default: 'png'
#' @param path character, path to save tex_preview outputs, if NULL then tempdir is used, Default: NULL
#' @param token A Slack token (either a user token or a bot user token)
#' @param bot_user_oauth_token Deprecated. A Slack bot user OAuth token
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
                       bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN"),
                       ...) {
  token <- check_tokens(token, bot_user_oauth_token)

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

  res <- POST(
    url = "https://slack.com/api/files.upload",
    add_headers(`Content-Type` = "multipart/form-data"),
    body = list(
      file = upload_file(file.path(td, paste0("slack.", ext))),
      token = token,
      channels = channels
    )
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
