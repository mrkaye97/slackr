prex_r <- utils::getFromNamespace("prex_r", "reprex")

quiet_auth <- function(token) {
  suppressWarnings(auth_test(token))$ok
}
