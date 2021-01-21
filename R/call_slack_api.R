GET <- "GET"
POST <- "POST"

#' A wrapper function to call the Slack API with authentication and pagination.
#'
#' @inheritParams auth_test
#'
#' @param path The API definition path, e.g. `/api/auth.test`
#' @param ... These arguments must be named and will be added to the API query string
#' @param body If `.method = POST` the `body` gets passed to the API body
#' @param .method Either "GET" or "POST"
#' @param .verbose If TRUE, prints `httr` verbose messages.  Useful for debugging.
#' @param .next_cursor The value of the next cursor, when using pagination.
#'
#' @return The API response (a named list)
#' @export
#'
call_slack_api <- function(
  path, ..., body = NULL, .method = c("GET", "POST"),
  bot_user_oauth_token,
  .verbose = Sys.getenv("SLACKR_VERBOSE", "FALSE"),
  .next_cursor = ""

) {
  if (missing(bot_user_oauth_token) || is.null(bot_user_oauth_token)) {
    bot_user_oauth_token <- Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN", "")
  }
  if (is.null(bot_user_oauth_token) || bot_user_oauth_token == "") {
    warning("Provide a value for bot_user_oauth_token",
            immediate. = TRUE,
            call. = FALSE)
  }
  url <- "https://slack.com"
  .method <- match.arg(.method)

  # Set locale to C (POSIX)
  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  # Make verbose call if env var is set
  if (.verbose == "TRUE") {
    old_config <- set_config(httr::verbose())
    on.exit(set_config(old_config), add = TRUE)
  } #else {
  #   set_config(httr::verbose(data_out = FALSE, data_in = FALSE, info = FALSE, ssl = FALSE))
  # }

  # Set up the API call
  call_api <- function() {
    if (.method == "GET") {
      httr::GET(
        url = url,
        path = path,
        httr::add_headers(
          .headers = c(Authorization = paste("Bearer", bot_user_oauth_token))
        ),
        query = add_cursor_get(..., .next_cursor = .next_cursor)
        # ...
      )
    } else if (.method == "POST") {
      httr::POST(
        url = url,
        path = path,
        httr::add_headers(
          .headers = c(Authorization = paste("Bearer", bot_user_oauth_token))
        ),
        body = add_cursor_post(body, .next_cursor = .next_cursor)
      )
    }
  }

  resp <- call_api()
  stop_for_status(resp)
  resp
}


add_cursor_get = function(..., .next_cursor = "") {
  z <- list(...)
  if (!is.null(.next_cursor) && .next_cursor != "") {
    message("Appending cursor to query")
    z <- append(z, list(cursor = .next_cursor))
  }
  z
}

add_cursor_post = function(..., .next_cursor = "") {
  z <- list(...)[[1]]
  if (!is.null(.next_cursor) && .next_cursor != "") {
    message("Appending cursor to query")
    z <- append(z, list(cursor = .next_cursor))
  }
  z
}




# POST("https://slack.com/api/conversations.list?limit=500&types=public_channel,private_channel",
# httr::add_headers(Authorization = bot_user_oauth_token))

get_next_cursor <- function(x) {
  content(x)[["response_metadata"]][["next_cursor"]]
}


#' Calls the slack API with pagination using cursors.
#'
#' @description
#' This loops over `fun`, extracts the `next_cursor` from the API response, and
#' injects this into the next loop.  At the completion of each loop, the function [convert_response_to_tibble()] is run with `extract` as and argument. The results are combined with [dplyr::bind_rows()]
#'
#' @param fun A function that calls the slack API
#' @param extract The name of the element to extract from the API reponse
#'
#' @return A `tibble`
#' @seealso call_slack_api
#' @export
#'
with_pagination <- function(fun, extract) {
  done <- FALSE
  old_cursor <- ""
  next_cursor <- ""
  result = NA
  while (!done) {
    # make the api call
    r <- match.fun(fun)(cursor = next_cursor)
    # retrieve the next cursor
    gn <- get_next_cursor(r)

    if (is.null(gn) || gn == "") {
      done <- TRUE
      next_cursor <- ""
    } else {
      if (gn == old_cursor) stop("Repeating cursor: ", gn)
      message("Cursoring: ", gn)
      old_cursor <- next_cursor
      next_cursor <- gn
      # Sys.sleep(0.1)
    }
    if (isTRUE(is.na(result))) {
      result <- convert_response_to_tibble(r, extract)
    } else {
      result <- bind_rows(
        result, convert_response_to_tibble(r, extract)
      )
    }
  }
  result
}


#' Checks authentication & identity against the Slack API.
#'
#' @param bot_user_oauth_token The Slack bot OAuth token {character vector}
#'
#' @references https://api.slack.com/methods/auth.test
#' @export
#'
#' @examples
#' if (Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN") != "") {
#'   auth_test()
#' }
auth_test <- function(bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {
  call_slack_api(
    "/api/auth.test",
    .method = GET,
    bot_user_oauth_token = bot_user_oauth_token,
    types = "public_channel,private_channel"
  ) %>%
    content()
}

#' Convert Slack API json response to tibble.
#'
#' @param x The Slack API response object, returned from [call_slack_api]
#' @param element The name of the list element to extract
#'
#' @return A tibble
#' @keywords Internal
#' @export
convert_response_to_tibble <- function(x, element) {
  as_tibble(
    jsonlite::fromJSON(content(x, as = "text"))[[element]]
  )
}
