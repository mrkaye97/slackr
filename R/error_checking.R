
okContent <- function(tmp){
  content_response <- jsonlite::fromJSON(httr::content(tmp, as="text"))
  if(content_response$ok != TRUE){
    error_message <- paste0("Calling function: ", paste0(sys.call(-1),collapse = "::"),
                            "\n   had error: ",
                            paste(content_response$error, collapse = " : "),
                            "\n   Needed: ", content_response$needed)
    stop(error_message)
  }
}
