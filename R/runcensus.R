#' @name runcensus
#' @title  Get a census of all users, channels, and groups in your Slack workspace
#' @description  Gathers all the channels, users, ims and groups of your slack workspace into a single object.
#' @author Daniel Egan [ctb]
#' @param api_token the Slack full API token (chr)
#' @return list consisting of
#' \itemize{
#'   \item{channels}
#'   \item{ims}
#'   \item{users}
#'   \item{groups}
#' }
#' @export
#' @examples
#' \dontrun{
#' creds <- yaml::yaml.load_file(input = "~/src/slackr_creds.yml")
#' slackr_census <- slackr_runcensus(creds)
#' }

runcensus <- function(api_token){
  return(
    list(
      channels = slackr::slackr_channels(api_token),
      ims      = slackr::slackr_ims(api_token),
      users    = slackr::slackr_users(api_token),
      groups   =  slackr::slackr_groups(api_token)
      )
    )
}
