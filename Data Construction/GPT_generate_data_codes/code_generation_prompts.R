
#######################################
# Get response with files with gpt
#######################################
gpt_response_with_files <- function(
    instructions,
    file_ids,
    user_text   = "Use the attached code files to perform the mediation-dataset reconstruction task described in the instructions.",
    model       = "gpt-4o-mini",
    temperature = 0,
    api_key     = Sys.getenv("OPENAI_API_KEY"),
    api_base    = "https://api.openai.com/v1",
    store       = FALSE  # don't store conversation server-side
) {
  if (!nzchar(api_key)) {
    stop("API key is empty. Set OPENAI_API_KEY or pass api_key explicitly.")
  }
  
  # Build content: many input_file parts + one input_text
  file_items <- lapply(file_ids, function(fid) {
    list(type = "input_file", file_id = fid)
  })
  
  text_item <- list(type = "input_text", text = user_text)
  
  body <- list(
    model        = model,
    instructions = instructions,
    input = list(list(
      role    = "user",
      content = c(file_items, list(text_item))
    )),
    temperature  = temperature,
    store        = store,
    text         = list(format = list(type = "text"))
  )
  
  req <- request(paste0(api_base, "/responses")) |>
    req_auth_bearer_token(api_key) |>
    req_body_json(body) |>
    req_error(is_error = function(resp) FALSE)
  
  resp   <- req_perform(req)
  status <- resp_status(resp)
  
  if (status >= 400) {
    cat("Responses API call failed with HTTP status:", status, "\n")
    cat("Response body:\n")
    cat(resp_body_string(resp), "\n")
    stop("Responses API call failed with HTTP ", status, call. = FALSE)
  }
  
  return(resp)

}
