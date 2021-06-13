#' Get a data frame of Slack users
#'
#' @param token the Slack bot OAuth token (chr)
#' @return `data.frame` of users
#' @importFrom dplyr bind_cols setdiff
#' @export
slackr_users <- function(token = Sys.getenv("SLACK_TOKEN"), bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {

  check_tokens(token, bot_user_oauth_token)

  members <- list_users()
  cols <- setdiff(colnames(members), c("profile", "real_name"))
  bind_cols(
    members[, cols],
    members$profile
  )
}

#' Get a data frame of Slack channels
#'
#' @param token the Slack bot OAuth token (chr)
#' @importFrom dplyr bind_rows
#' @return data.table of channels
#' @export
slackr_channels <- function(token = Sys.getenv("SLACK_TOKEN"), bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {

  check_tokens(token, bot_user_oauth_token)

  c1 <- list_channels(token = token, types = "public_channel")
  c2 <- list_channels(token = token, types = "private_channel")

  bind_rows(c1, c2)
}

#' Get a data frame of Slack IM ids
#'
#' @param token the Slack both OAuth token (chr)
#' @importFrom dplyr left_join
#'
#' @author Quinn Weber (aut), Bob Rudis (ctb)
#' @references <https://github.com/mrkaye97/slackr/pull/13>
#' @return `data.frame` of im ids and user names
#' @export
slackr_ims <- function(token = Sys.getenv("SLACK_TOKEN"), bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {

  check_tokens(token, bot_user_oauth_token)

  loc <- Sys.getlocale("LC_CTYPE")
  Sys.setlocale("LC_CTYPE", "C")
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  ims <- list_channels(token = token, types = "im")
  users <- slackr_users(token = token)

  if ((nrow(ims) == 0) | (nrow(users) == 0)) {
    abort("slackr is not seeing any users in your workspace. Are you sure you have the right scopes enabled? See the readme for details.")
  }

  left_join(users, ims, by = "id")
}

#' Check for token issues
#'
#' @param token a token
#' @param bot_user_oauth_token another token
#' @return No return value. Called for side effects
check_tokens <- function(token, bot_user_oauth_token) {

  if (token == "" & bot_user_oauth_token == "") {
    abort("No token found. Did you forget to call `slackr_setup()`?")
  }

  if (bot_user_oauth_token != "") {
    warn("The use of `bot_user_oauth_token` is deprecated as of `slackr 3.0.0`. Please use `token` instead.")
  }

  if (token != "" & bot_user_oauth_token != "" & token != bot_user_oauth_token) {
    abort(
      "You specified both a `token` and a `bot_user_oauth_token`, and the two were not the same. Please only specify a `token`."
    )
  }

  invisible()
}