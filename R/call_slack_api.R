GET <- "GET"
POST <- "POST"

#' Internal function to warn if Slack API call is not ok.
#'
#' The function is called for the side effect of warning when the API response
#' has errors, and is a thin wrapper around httr::stop_for_status
#'
#' @param r The response from a call to the Slack API
#'
#' @return NULL
#' @importFrom httr status_code content
#' @keywords Internal
#' @noRd
#'
stop_for_status <- function(r) {
  # note that httr::stop_for_status should be called explicitly

  httr::stop_for_status(r)
  cr <- content(r, encoding = "UTF-8")

  # A response code of 200 doesn't mean everything is ok, so check if the
  # response is not ok
  if (status_code(r) == 200 && !is.null(cr$ok) && !cr$ok) {
    error_msg <- cr$error
    cr$ok <- NULL
    cr$error <- NULL
    additional_msg <- paste(
      sapply(seq_along(cr), function(i) paste(names(cr)[i], ":=", unname(cr)[i])),
      collapse = "\n"
    )
    warn(
      sprintf(
        "The slack API returned an error: %s \r\n%s",
        error_msg,
        additional_msg
      )
    )
  }

  invisible()
}

#' with_retry
#'
#' @param fun fun
#'
#' @return r
#' @importFrom httr headers
#' @keywords Internal
#' @noRd
#'
with_retry <- function(fun) {
  ok <- FALSE
  while (!ok) {
    r <- fun()
    if (r$status_code == 429) {
      retry_after <- headers(r)[["retry-after"]]
      inform("\nPausing for ", retry_after, " seconds due to Slack API rate limit")
      Sys.sleep(retry_after)
    } else {
      ok <- TRUE
    }
  }
  r
}

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
#' @importFrom httr add_headers verbose set_config GET POST
#'
#' @return The API response (a named list)
#' @export
#'
call_slack_api <- function(path, ..., body = NULL, .method = c("GET", "POST"),
                           token,
                           .verbose = Sys.getenv("SLACKR_VERBOSE", "FALSE"),
                           .next_cursor = "") {
  if (missing(token) || is.null(token)) {
    token <- Sys.getenv("SLACK_TOKEN", "")
  }
  if (is.null(token) || token == "") {
    warn("Provide a value for token")
  }

  url <- "https://slack.com"
  .method <- match.arg(.method)

  # Make verbose call if env var is set
  if (.verbose == "TRUE") {
    old_config <- set_config(verbose())
    on.exit(set_config(old_config), add = TRUE)
  } # else {
  #   set_config(httr::verbose(data_out = FALSE, data_in = FALSE, info = FALSE, ssl = FALSE))
  # }

  # Set up the API call
  call_api <- function() {
    if (.method == "GET") {
      GET(
        url = url,
        path = path,
        add_headers(
          .headers = c(Authorization = paste("Bearer", token))
        ),
        query = add_cursor_get(..., .next_cursor = .next_cursor)
        # ...
      )
    } else if (.method == "POST") {
      POST(
        url = url,
        path = path,
        add_headers(
          .headers = c(Authorization = paste("Bearer", token))
        ),
        body = add_cursor_post(body, .next_cursor = .next_cursor)
      )
    }
  }

  resp <- with_retry(call_api)
  stop_for_status(resp)
  resp
}


add_cursor_get <- function(..., .next_cursor = "") {
  z <- list(...)
  if (!is.null(.next_cursor) && .next_cursor != "") {
    # inform("Appending cursor to query")
    z <- append(z, list(cursor = .next_cursor))
  }
  z
}

add_cursor_post <- function(..., .next_cursor = "") {
  z <- list(...)[[1]]
  if (!is.null(.next_cursor) && .next_cursor != "") {
    inform("Appending cursor to query")
    z <- append(z, list(cursor = .next_cursor))
  }
  z
}




# POST("https://slack.com/api/conversations.list?limit=500&types=public_channel,private_channel",
# httr::add_headers(Authorization = token))

get_next_cursor <- function(x) {
  content(x)[["response_metadata"]][["next_cursor"]]
}


get_retry_after <- function(x) {

}


#' Calls the slack API with pagination using cursors.
#'
#' @description
#' This loops over `fun`, extracts the `next_cursor` from the API response, and
#' injects this into the next loop.  At the completion of each loop, the function [convert_response_to_tibble()] is run with `extract` as and argument. The results are combined with [dplyr::bind_rows()]
#'
#' @param fun A function that calls the slack API
#' @param extract The name of the element to extract from the API response
#'
#' @return A `tibble`
#' @seealso call_slack_api
#' @export
#'
with_pagination <- function(fun, extract) {
  done <- FALSE
  old_cursor <- ""
  next_cursor <- ""
  result <- NA
  had_to_cursor <- FALSE
  while (!done) {
    # make the api call
    r <- match.fun(fun)(cursor = next_cursor)
    # retrieve the next cursor
    gn <- get_next_cursor(r)
    # gr <- get_retry_after(r)

    if (is.null(gn) || gn == "") {
      done <- TRUE
      next_cursor <- ""
    } else {
      if (gn == old_cursor) abort("Repeating cursor: ", gn)
      inform(".", appendLF = FALSE)
      had_to_cursor <- TRUE
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
  if (had_to_cursor) inform("")
  result
}


#' Checks authentication & identity against the Slack API.
#'
#' @param token The Slack bot OAuth token {character vector}
#' @param bot_user_oauth_token Deprecated
#'
#' @references https://api.slack.com/methods/auth.test
#' @export
#' @importFrom magrittr %>%
#' @importFrom jsonlite fromJSON
#'
#' @examples
#' if (Sys.getenv("SLACK_TOKEN") != "") {
#'   auth_test()
#' }
auth_test <- function(token = Sys.getenv("SLACK_TOKEN"), bot_user_oauth_token = Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN")) {
  if (bot_user_oauth_token != "") warn("The use of `bot_user_oauth_token` is deprecated as of `slackr 2.4.0`. Please use `token` instead.")

  call_slack_api(
    "/api/auth.test",
    .method = GET,
    token = token,
    types = "public_channel,private_channel"
  ) %>%
    content()
}

#' Convert Slack API json response to tibble.
#'
#' @param x The Slack API response object, returned from [call_slack_api]
#' @param element The name of the list element to extract
#' @importFrom magrittr %>%
#' @importFrom jsonlite fromJSON
#' @importFrom tibble as_tibble
#' @importFrom httr content
#'
#' @return A tibble
#' @keywords Internal
#' @export
convert_response_to_tibble <- function(x, element) {
  as_tibble(
    fromJSON(content(x, as = "text"))[[element]]
  )
}
