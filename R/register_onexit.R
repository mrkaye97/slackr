#' @title Append text_slackr as on.exit to functions.
#' @description Appends to the body of a function an on.exit call to run at the end of the call.
#' @param f function or character
#' @param msg character, message to pass to text_slackr Default: 'done!'
#' @param env environment to assign appended function to with relation to the function environment,
#' Default: parent.frame(2) (global environment)
#' @inherit text_slackr
#' @return function
#' @details If a character is passed to f then it will evaluate internally to a function.
#' @examples
#' \dontrun{
#' ctl <- c(4.17,5.58,5.18,6.11,4.50,4.61,5.17,4.53,5.33,5.14)
#' trt <- c(4.81,4.17,4.41,3.59,5.87,3.83,6.03,4.89,4.32,4.69)
#' group <- gl(2, 10, 20, labels = c("Ctl","Trt"))
#' weight <- c(ctl, trt)
#' register_onexit(lm,channel="general")
#' lm.D9 <- slack_lm(weight ~ group)
#' }
#' @rdname register_onexit
#' @seealso
#' \code{\link{text_slackr}}
#' @author Jonathan Sidi [aut]
#' @export
register_onexit <- function(f,
                            msg='done!',
                            env=parent.frame(2),
                            channel = Sys.getenv("SLACK_CHANNEL"),
                            username = Sys.getenv("SLACK_USERNAME"),
                            icon_emoji = Sys.getenv("SLACK_ICON_EMOJI"),
                            api_token = Sys.getenv("SLACK_API_TOKEN")){

  f.val <- deparse(match.call()[[2]])

  if(inherits(f,'character')) f <- eval(parse(text = f))

  msg <- sprintf('%s : %s', f.val, msg)

  b <- body(f)

  tmp <- b[[length(b)]]

  b[[length(b)]] <- substitute(on.exit({text_slackr(msg,
                                                      channel=channel,
                                                      username=username,
                                                      icon_emoji = icon_emoji,
                                                      api_token = api_token)},add = TRUE))

  b[[length(b)+1]] <- tmp

  body(f) <- b

  if(!is.null(env)) assign(sprintf('slack_%s',f.val),envir = env,f)

  invisible(f)

}
