#' slackr - A package to work with the Slack API
#'
#' Mega thanks to:
#'
#' \itemize{
#'   \item [Jay Jacobs](https://github.com/jayjacobs)
#'   \item [David Severski](https://github.com/davidski)
#'   \item [Quinn Weber](https://github.com/qsweber)
#'   \item [Konrad Karczewski](https://github.com/konradjk)
#'   \item [Ed Niles](https://github.com/eniles)
#'   \item [Rick Saporta](https://github.com/rsaporta)
#' }
#'
#' for their contributions to the package!
#'
#' Check out:
#' \itemize{
#'   \item the [slackr] function to send messages,
#'   \item the [dev_slackr] function to send images (copies from current graphics device)
#'   \item the [ggslackr] function to send ggplot objects (without plotting to a device first)
#'   \item the [save_slackr] function to send R objects (as RData files)
#'   \item the [slackr_upload] function to send files
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
