prex_r <- utils::getFromNamespace("prex_r", "reprex")
quiet_prex <- purrr::quietly(prex_r)

quiet_auth <- purrr::quietly(auth_test)
