#' @title Append slackr_msg as on.exit to functions.
#' @description Appends to the body of a function an on.exit call to run at the end of the call.
#' @param f function or character
#' @param ... expressions to be sent to Slack
#' @param header_msg boolean, message to append to start of Slack output, Default: NULL
#' @param use_device boolean, passes current image in the graphics device to Slack as part of f,
#' Default: FALSE
#' @param env environment to assign appended function to with relation to the function environment,
#' Default: parent.frame(2) (global environment)
#' @inherit slackr
#' @return function
#' @details If a character is passed to f then it will evaluate internally to a function.
#' @examples
#' \dontrun{
#' ctl <- c(4.17, 5.58, 5.18, 6.11, 4.50, 4.61, 5.17, 4.53, 5.33, 5.14)
#' trt <- c(4.81, 4.17, 4.41, 3.59, 5.87, 3.83, 6.03, 4.89, 4.32, 4.69)
#' group <- gl(2, 10, 20, labels = c("Ctl", "Trt"))
#' weight <- c(ctl, trt)
#'
#' # pass a message to Slack channel 'general'
#' register_onexit(lm, "bazinga!", channel = "#general")
#'
#' lm.D9 <- slack_lm(weight ~ group)
#'
#' # test that output keeps inheritance
#' summary(lm.D9)
#'
#' # pass a message to Slack channel 'general' with a header message to begin output
#' register_onexit(lm, "bazinga!",
#'   channel = "#general",
#'   header_msg = "This is a message to begin"
#' )
#'
#' lm.D9 <- slack_lm(weight ~ group)
#'
#' # onexit with an expression that calls lm.plot
#' register_onexit(lm,
#'   {
#'     par(mfrow = c(2, 2), oma = c(0, 0, 2, 0))
#'     plot(z)
#'   },
#'   channel = "#general",
#'   header_msg = "This is a plot just for this output",
#'   use_device = TRUE
#' )
#'
#' lm.D9 <- slack_lm(weight ~ group)
#'
#' # clean up slack channel from examples
#' slackr_delete(count = 6, channel = "#general")
#' }
#'
#' @seealso
#' [slackr_msg()]
#' @author Jonathan Sidi (aut)
#' @export
register_onexit <- function(f,
                            ...,
                            header_msg = NULL,
                            use_device = FALSE,
                            env = parent.frame(2),
                            channel = Sys.getenv("SLACK_CHANNEL"),
                            username = Sys.getenv("SLACK_USERNAME"),
                            icon_emoji = Sys.getenv("SLACK_ICON_EMOJI"),
                            bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {
  f.val <- deparse(match.call()[[2]])

  if (inherits(f, "character")) f <- eval(parse(text = f))

  if (!is.null(header_msg)) {
    header_msg <- sprintf("%s : %s", f.val, header_msg)
  }

  b <- body(f)

  tmp <- b[[length(b)]]

  b[[length(b)]] <- substitute(on.exit(
    {
      if (!is.null(header_msg)) {
        slackr(header_msg, channel = channel, username = username, icon_emoji = icon_emoji, bot_user_oauth_token = bot_user_oauth_token)
      }

      slackr(..., channel = channel, username = username, icon_emoji = icon_emoji, bot_user_oauth_token = bot_user_oauth_token)

      if (use_device & !is.null(dev.list())) {
        slackr_dev(channels = channel, bot_user_oauth_token = bot_user_oauth_token)
      }
    },
    add = TRUE
  ))

  b[[length(b) + 1]] <- tmp

  body(f) <- b

  if (!is.null(env)) assign(sprintf("slack_%s", f.val), envir = env, f)

  invisible(f)
}
