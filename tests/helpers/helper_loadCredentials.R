#' @name loadCredentials
#' @title Load database, API, or service creds from a local YAML file
#' @author Sam Swift
#' @description We store DB access credentials, API secrets, and authetication
#' tokens in a local YAML file, by default at ~/src/bettercreds.yaml. This
#' function handles loading and delivering those creds. Returns a named list
#' of credential parameters.
#' @param service.name the identifier of the service for which you're requesting creds.
#' This should match the YAML block title or correspond to env variables you have set
#' @param yaml.path absolute file path to the YAML file containing the desired creds
#' @importFrom yaml yaml.load_file
#' @export loadCreds

loadCredentials <- function(service.name,
                      yaml.path = file.path("~","src","credentials.yaml")){

  # check for required service.name
  if(is.null(service.name)){
    stop(Sys.time(),
         " loadCreds: No yaml service.name specified. Which creds do you want?")
  }

  # before checking yaml, see if we have the creds set as Env variables
  # this is common in our testing environment (currently, TravisCI)
  # if set, we expect a string that can be cast as a list
  # ex. "token=09384209384234098,othervalue='sdfsdff'"
  if(service.name %in% names(Sys.getenv())){
    env.creds <- Sys.getenv(x = service.name)
    env.creds <- try(eval(parse(text = paste0("list(",env.creds,")"))),silent = TRUE)
    if(class(env.creds) == "list" & length(env.creds) > 0){
      message(Sys.time(),
              " loadCreds: using Sys.env() value for ", service.name)
      return(env.creds)
    } else {
      warning(Sys.time(),
              " loadCreds: ", service.name,
              " found in Sys.env, but value did not parse successfully: ",
              Sys.getenv(x = service.name))
    }
  }

  # If the YAML file is found, load it
  if(file.exists(yaml.path)){
    config <- yaml.load_file(yaml.path)

    # if a non-default path was given, but not found, error
  } else if(yaml.path != file.path("~","src","bettercreds.yaml") &
            !file.exists(yaml.path)){
    stop(Sys.time(),
         " loadCreds: YAML config file not found at: '", yaml.path,"'
         Your YAML file should include a block for each database you have configured, like this:
         datawarehouse:
            username : [your_username]
            password : [your_password]
            host : [db host, e.g. prod-datawarehouse-db-replica.betterment.com]
            port : 3306")

    # if the default was given but not found, check the previous default locations
    # and communicate the move
  }

  # find requested block
  if(service.name %in% names(config)){
    creds <- config[[service.name]]
    return(creds)
  } else {
    stop(Sys.time(),
         " loadCreds: YAML file found, but doesn't contain param block for '",
         service.name, "'")
  }
}