#' Check for token-parameter mismatches
#'
#' @param token Authentication token bearing required scopes.
#' @param ... Additiional arguments passed to the function called.
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
