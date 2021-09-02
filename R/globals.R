quiet_auth <- function(token) {
  suppressWarnings(auth_test(token))$ok
}
