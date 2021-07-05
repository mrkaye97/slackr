#' Check for token issues
#'
#' @param token a token
#' @param bot_user_oauth_token another token
#' @importFrom lifecycle deprecate_warn
#' @importFrom rlang as_string
#' @return A token
check_tokens <- function(token, bot_user_oauth_token) {
  calling_fun <- tryCatch(
    {
      as_string(as.list(sys.call(-1))[[1]])
    },
    error = function(e) "an unknown function"
  )
  dep_arg1 <- sprintf("%s(bot_user_oauth_token)", calling_fun)
  dep_arg2 <- sprintf("%s(token)", calling_fun)

  if (token == "" & bot_user_oauth_token == "") {
    abort("No token found. Did you forget to call `slackr_setup()`?")
  }

  if (token != "" & bot_user_oauth_token != "" & token != bot_user_oauth_token) {
    abort(
      "You specified both a `token` and a `bot_user_oauth_token`, and the two were not the same. Please only specify a `token`."
    )
  }

  if (bot_user_oauth_token != "") {
    deprecate_warn("2.4.0", dep_arg1, dep_arg2)

    return(bot_user_oauth_token)
  }

  return(token)
}

#' Check for token-parameter mismatches
#'
#' @param token a token
#' @param ... Additiional arguments passed to the function called
#' @return No return value. Called for side effects
warn_for_args <- function(token, ...) {
  if (substr(token, 1L, 4L) == "xoxp") {
    all_args <- list(...)
    non_missing_args <- all_args[all_args != ""]

    num_non_missing <- length(non_missing_args)
    if (num_non_missing > 0) {
      sing_plur <- if (num_non_missing > 1) "These arguments" else "This argument"

      warn(
        sprintf(
          "You're using a user token but also specified the following parameter(s): %s. %s will have no effect.",
          paste(names(non_missing_args), collapse = ", "),
          sing_plur
        ),
        .frequency = "once",
        .frequency_id = "df0f12c9-9718-4edf-99ac-7ec1f34687ec"
      )
    }
  }

  invisible()
}
