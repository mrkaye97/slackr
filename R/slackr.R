#' Output R expressions to a Slack channel/user
#'
#' Takes an \code{expr}, evaluates it and sends the output to a Slack
#' chat destination. Useful for logging, messaging on long compute tasks or
#' general information sharing.
#'
#' By default, everyting but \code{expr} will be looked for in a "\code{SLACK_}"
#' environment variable. You can override or just specify these values directly instead,
#' but it's probably better to call \code{\link{slackr_setup}} first.
#'
#' @param ... expressions to be sent to Slack.com
#' @param channel which channel to post the message to (chr)
#' @param username what user should the bot be named as (chr)
#' @param icon_emoji what emoji to use (chr) \code{""} will mean use the default
#' @param api_token your full slack.com API token
#' @note You need a \url{https://www.slack.com} account and will also need to
#'       setup an API token \url{https://api.slack.com/}
#'       Also, you can pass in \code{add_user=TRUE} as part of the \code{...}
#'       parameters and the Slack API will post the message as your logged-in
#'       user account (this will override anything set in \code{username})
#' @seealso \code{\link{slackr_setup}}, \code{\link{slackr_bot}}, \code{\link{dev_slackr}},
#'          \code{\link{save_slackr}}, \code{\link{slackr_upload}}
#' @examples
#' \dontrun{
#' slackr_setup()
#' slackr("iris info", head(iris), str(iris))
#' }
#' @export
slackr <- function(...,
                   channel=Sys.getenv("SLACK_CHANNEL"),
                   username=Sys.getenv("SLACK_USERNAME"),
                   icon_emoji=Sys.getenv("SLACK_ICON_EMOJI"),
                   api_token=Sys.getenv("SLACK_API_TOKEN")) {

  if (api_token == "") {
    stop("No token specified. Did you forget to call slackr_setup()?", call. = FALSE)
  }

  resp_ret <- ""

  if (!missing(...)) {

    # mimics capture.output

    # get the arglist
    args <- substitute(list(...))[-1L]

    # setup in-memory sink
    rval <- NULL
    fil <- textConnection("rval", "w", local = TRUE)

    sink(fil)
    on.exit({
      sink()
      close(fil)
    })

    # where we'll need to eval expressions
    pf <- parent.frame()

    # how we'll eval expressions
    evalVis <- function(expr) withVisible(eval(expr, pf))

    # for each expression
    for (i in seq_along(args)) {

      expr <- args[[i]]

      # do something, note all the newlines...Slack ``` needs them
      tmp <- switch(mode(expr),
                    # if it's actually an expresison, iterate over it
                    expression = {
                      cat(sprintf("> %s\n", deparse(expr)))
                      lapply(expr, evalVis)
                    },
                    # if it's a call or a name, eval, printing run output as if in console
                    call = ,
                    name = {
                      cat(sprintf("> %s\n", deparse(expr)))
                      list(evalVis(expr))
                    },
                    # if pretty much anything else (i.e. a bare value) just output it
                    integer = ,
                    double = ,
                    complex = ,
                    raw = ,
                    logical = ,
                    numeric = cat(sprintf("%s\n\n", as.character(expr))),
                    character = cat(sprintf("%s\n\n", expr)),
                    stop("mode of argument not handled at present by slackr"))

      for (item in tmp) if (item$visible) { print(item$value); cat("\n") }
    }

    on.exit()

    sink()
    close(fil)

    # combined all of them (rval is a character vector)
    output <- paste0(rval, collapse="\n")

    loc <- Sys.getlocale('LC_CTYPE')
    Sys.setlocale('LC_CTYPE','C')
    on.exit(Sys.setlocale("LC_CTYPE", loc))

    resp <- POST(url="https://slack.com/api/chat.postMessage",
                 body=list(token=api_token,
                           channel=slackr_chtrans(channel),
                           username=username,
                           icon_emoji=icon_emoji,
                           as_user=TRUE,
                           text=sprintf("```%s```", output),
                           link_names=1))

    warn_for_status(resp)

  }

  return(invisible())

}

#' Output R expressions to a Slack channel/user
#'
#' Takes an \code{expr}, evaluates it and sends the output to a Slack
#' chat destination. Useful for logging, messaging on long compute tasks or
#' general information sharing.
#'
#' By default, everyting but \code{expr} will be looked for in a "\code{SLACK_}"
#' environment variable. You can override or just specify these values directly instead,
#' but it's probably better to call \code{\link{slackrSetup}} first.
#'
#' @param txt text message to send to Slack. If a character vector of length > 1
#'        is passed in, they will be combined and separated by newlines.
#' @param channel which channel to post the message to (chr)
#' @param username what user should the bot be named as (chr)
#' @param icon_emoji what emoji to use (chr) \code{""} will mean use the default
#' @param api_token your full slack.com API token
#' @param ... other arguments passed to the Slack API \code{chat.postMessage} call
#' @note You need a \url{https://www.slack.com} account and will also need to
#'       setup an API token \url{https://api.slack.com/}
#'       Also, you can pass in \code{add_user=TRUE} as part of the \code{...}
#'       parameters and the Slack API will post the message as your logged-in
#'       user account (this will override anything set in \code{username})
#' @seealso \code{\link{slackr_setup}}, \code{\link{slackr_bot}}, \code{\link{dev_slackr}},
#'          \code{\link{save_slackr}}, \code{\link{slackr_upload}}
#' @examples
#' \dontrun{
#' slackr_setup()
#' slackr_msg("Hi")
#' }
#' @export
slackr_msg <- function(txt="",
                       channel=Sys.getenv("SLACK_CHANNEL"),
                       username=Sys.getenv("SLACK_USERNAME"),
                       icon_emoji=Sys.getenv("SLACK_ICON_EMOJI"),
                       api_token=Sys.getenv("SLACK_API_TOKEN"),
                       ...) {

  if (api_token == "") {
    stop("No token specified. Did you forget to call slackr_setup()?", call. = FALSE)
  }

  if (icon_emoji != "") { icon_emoji <- sprintf(', "icon_emoji": "%s"', icon_emoji)  }

  output <- paste0(txt, collapse="\n\n")

  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE','C')
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  resp <- POST(url="https://slack.com/api/chat.postMessage",
               body=list(token=api_token,
                         channel=slackr_chtrans(channel),
                         username=username,
                         icon_emoji=icon_emoji,
                         text=output,
                         as_user=TRUE,
                         link_names=1,
                         ...))

  warn_for_status(resp)

  return(invisible())

}
