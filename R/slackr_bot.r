#' Send result of R expressions to a Slack channel via webhook API
#'
#' Takes an `expr`, evaluates it and sends the output to a Slack
#' chat destination via the webhook API. Useful for logging, messaging on long
#' compute tasks or general information sharing.
#'
#' By default, everything but `expr` will be looked for in a "`SLACK_`"
#' environment variable. You can override or just specify these values directly
#' instead, but it's probably better to call [slackr_setup()] first.
#'
#'
#' @param ... expressions to be sent to Slack.
#' @param incoming_webhook_url which `slack.com` API endpoint URL to use
#'   (see section **Webhook URLs** for details).
#' @importFrom utils URLencode
#' @importFrom rlang warn abort
#' @note You need a <https://www.slack.com> account and will also need to
#'   setup an incoming webhook: <https://api.slack.com/>. Old style webhooks are
#'   no longer supported.
#' @seealso [slackr_setup()], [slackr()],
#'   [slackr_dev()], [slackr_save()],
#'   [slackr_upload()]
#' @section Webhook URLs: Webhook URLs look like: \itemize{
#'
#'   \item `https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX`
#'
#'   }
#'
#' OLD STYLE WEBHOOKS ARE NO LONGER SUPPORTED
#'
#' @examples
#' \dontrun{
#' slackr_setup()
#' slackr_bot("iris info", head(iris), str(iris))
#'
#' # or directly
#' slackr_bot("Test message",
#'   incoming_webhook_url = "https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX"
#' )
#' }
#' @export
slackr_bot <- function(..., incoming_webhook_url = Sys.getenv("SLACK_INCOMING_WEBHOOK_URL")) {
  local_options(list(cli.num_colors = 1))

  if (incoming_webhook_url == "" | is.na(incoming_webhook_url)) {
    abort("No incoming webhook URL specified. Did you forget to call slackr_setup()?")
  }

  if (!missing(...)) {
    ## map over each thing passed to `slackr` and evaluate it
    output <- map(
      args,
      ~ eval(call2(quiet_prex, .x, input = tempfile(), html_preview = FALSE, render = TRUE, style = FALSE))
    ) %>%
      map(
        ~ .x %>%
          pluck("result") %>%
          discard(grepl("```", .)) %>%
          modify_at(
            c(1),
            function(s) paste(">", s)
          ) %>%
          paste(collapse = "\n")
      ) %>%
      paste(collapse = "\n\n")

    resp <- POST(
      url = incoming_webhook_url,
      encode = "form",
      add_headers(
        `Content-Type` = "application/x-www-form-urlencoded",
        Accept = "*/*"
      ),
      body = URLencode(
        sprintf(
          "payload={\"text\": \"```%s```\"}",
          output
        )
      )
    )
    stop_for_status(resp)
  }
  return(invisible(resp))
}
