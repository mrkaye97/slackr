#' slackr - A package to work with the Slack.com API
#'
#' Mega thanks to:
#'
#' \itemize{
#'   \item \href{https://github.com/jayjacobs}{Jay Jacobs}
#'   \item \href{https://github.com/davidski}{David Severski}
#'   \item \href{https://github.com/qsweber}{Quinn Weber}
#'   \item \href{https://github.com/konradjk}{Konrad Karczewski}
#'   \item \href{https://github.com/eniles}{Ed Niles}
#'   \item \href{https://github.com/rsaporta}{Rick Saporta}
#' }
#'
#' for their contributions to the package!
#'
#' Check out:
#' \itemize{
#'   \item the \link{slackr} function to send messages,
#'   \item the \link{dev_slackr} function to send images (copies from current graphics device)
#'   \item the \link{ggslackr} function to send ggplot objects (without plotting to a device first)
#'   \item the \link{save_slackr} function to send R objects (as RData files)
#'   \item the \link{slackr_upload} function to send files
#' }
#'
#' @name slackr-package
#' @title slackr-package
#' @docType package
#' @author Bob Rudis (@@hrbrmstr)
#' @import httr ggplot2 utils methods
#' @importFrom dplyr data_frame left_join bind_rows
#' @importFrom jsonlite toJSON
#' @import utils
#' @importFrom grDevices dev.copy dev.off png
#' @importFrom graphics par
#' @examples
#' \dontrun{
#' slackr_setup()
#'
#' # send objects
#' slackr("iris info", head(iris), str(iris))
#'
#' # send images
#' library(ggplot2)
#' qplot(mpg, wt, data=mtcars)
#' dev.slack("#results")
#'
#' ggslackr(qplot(mpg, wt, data=mtcars))
#'
#' }
NULL
