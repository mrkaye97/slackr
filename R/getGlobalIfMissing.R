
getGlobalIfMissing <- function(x){
  assert_that(x %in% ls(envir = .GlobalEnv),
              msg = "slackr_census does't appear in the global environment yet. Have you run slackr_setup() yet?")
  get(x, envir = .GlobalEnv)
  }
#getGlobalIfMissing(x = "census_channels")
