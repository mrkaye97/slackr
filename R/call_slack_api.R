GET <- "GET"
POST <- "POST"

call_slack_api <- function(path, ..., body = NULL, .method = c("GET", "POST"),
                           bot_user_oauth_token,
                           .verbose = Sys.getenv("SLACKR_VERBOSE", FALSE)

) {
  if (missing(bot_user_oauth_token) || is.null(bot_user_oauth_token)) {
    bot_user_oauth_token <- Sys.getenv("SLACK_BOT_USER_OAUTH_TOKEN", "")
  }
  if (is.null(bot_user_oauth_token) || bot_user_oauth_token == "") {
    warning("Provide a value for bot_user_oauth_token", immediate. = TRUE, call. = FALSE)
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
  }

  # Set up the API call
  call_api <-function() {
    if (.method == "GET") {
      httr::GET(
        url = url,
        path = path,
        httr::add_headers(.headers = c(Authorization = paste("Bearer", bot_user_oauth_token))),
        query = add_cursor_get(...)
          # ...
      )
    } else if (.method == "POST") {
      httr::POST(
        url = url,
        path = path,
        httr::add_headers(.headers = c(Authorization = paste("Bearer", bot_user_oauth_token))),
        body = add_cursor_post(body)
      )
    }
  }

  resp <- call_api()
  stop_for_status(resp)
  resp
}


add_cursor_get = function(..., .next_cursor = SLACK_CURSOR$value) {
  z <- list(...)
  if (!is.null(.next_cursor) && .next_cursor != "") {
    message("Appending cursor to query")
    z <- append(z, list(cursor = .next_cursor))
  }
  z
}

add_cursor_post = function(..., .next_cursor = SLACK_CURSOR$value) {
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

SLACK_CURSOR <- new.env(parent = emptyenv())

with_pagination <- function(fun, extract) {
  done <- FALSE
  SLACK_CURSOR$value <<- ""
  old_cursor <- ""
  result = NA
  while (!done) {
    r <- match.fun(fun)()
    gn <- get_next_cursor(r)
    if (is.null(gn) || gn == "") {
      done <- TRUE
      SLACK_CURSOR$value <<-  ""
    } else {
      if (gn == old_cursor) stop("Repeating cursor: ", gn)
      message("Cursoring: ", gn)
      SLACK_CURSOR$value <<-  gn
      old_cursor <- gn
    }
    if (isTRUE(is.na(result))) {
      result <- r %>% convert_response_to_tibble(extract)
    } else {
      result <- bind_rows(
        result, r %>% convert_response_to_tibble(extract)
      )
    }
    Sys.sleep(0.5)
  }
  result
}


#' Checks authentication & identity against the Slack API.
#'
#' @param bot_user_oauth_token The Slack bot OAuth token <character vector>
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
    types = "public_channel,private_channel"
  ) %>%
    content()
}

#' Convert Slack API json response to tibble.
#'
#' @inheritParams list_channels
#' @param x The Slack API response object, returned from [call_slack_api]
#' @param element The name of the list element to extract
#'
#' @return A tibble
#' @noRd
convert_response_to_tibble <- function(x, element) {
  x %>%
    content(as = "text") %>%
    jsonlite::fromJSON() %>%
    .[[element]] %>%
    as_tibble()
}
