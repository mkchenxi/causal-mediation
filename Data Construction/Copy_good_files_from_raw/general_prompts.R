#############################################
# A generic function to promt gpt
#############################################
gpt_chat <- function(messages,
                     model = model_id,
                     temperature = 0) {
  req <- request(paste0(api_base, "/chat/completions")) |>
    req_auth_bearer_token(api_key) |>
    req_body_json(list(
      model    = model,
      messages = messages,
      temperature = temperature
    ))
  
  resp <- req_perform(req)
  data <- resp_body_json(resp)
  
  reply <- data$choices[[1]]$message
  
  list(
    reply    = reply,
    messages = append(messages, list(reply))
  )
}

###############################################
# Helper: upload a single file to OpenAI
###############################################

upload_file_to_openai <- function(
    path,
    purpose  = "user_data",  # or "assistants", "batch", "fine-tune", etc.
    api_key = Sys.getenv("OPENAI_API_KEY"),
    api_base = "https://api.openai.com/v1"
) {
  if (!file.exists(path)) {
    stop("File does not exist: ", path)
  }
  if (identical(api_key, "") || is.null(api_key)) {
    stop("API key is empty. Set OPENAI_API_KEY or pass api_key explicitly.")
  }
  
  # Need curl for curl::form_file()
  if (!requireNamespace("curl", quietly = TRUE)) {
    stop("Package 'curl' is required. Please install it with install.packages('curl').")
  }
  
  req <- httr2::request(paste0(api_base, "/files")) |>
    httr2::req_auth_bearer_token(api_key) |>
    httr2::req_body_multipart(
      # This makes 'file' an actual uploaded file, not just a string
      file    = curl::form_file(path),
      purpose = purpose
    ) |>
    # Don't throw on error so we can inspect the body
    httr2::req_error(is_error = function(resp) FALSE)
  
  resp   <- httr2::req_perform(req)
  status <- httr2::resp_status(resp)
  
  if (status >= 400) {
    cat("Upload failed with HTTP status:", status, "\n")
    cat("Response body:\n")
    cat(httr2::resp_body_string(resp), "\n")
    stop("Upload failed with HTTP ", status, call. = FALSE)
  }
  
  httr2::resp_body_json(resp)
}

#################################################
# Reading files from Open API /files
#################################################
list_openai_files <- function(
    api_key  = Sys.getenv("OPENAI_API_KEY"),
    api_base = "https://api.openai.com/v1"
) {
  if (!nzchar(api_key)) {
    stop("API key is empty. Set OPENAI_API_KEY or pass api_key explicitly.")
  }
  
  req <- request(paste0(api_base, "/files")) |>
    req_auth_bearer_token(api_key) |>
    req_error(is_error = function(resp) FALSE)
  
  resp   <- req_perform(req)
  status <- resp_status(resp)
  
  if (status >= 400) {
    cat("List files failed with HTTP status:", status, "\n")
    cat("Response body:\n")
    cat(resp_body_string(resp), "\n")
    stop("List files failed with HTTP ", status, call. = FALSE)
  }
  
  dat <- resp_body_json(resp)
  
  # dat$data is a list of file objects
  files <- dat$data
  if (length(files) == 0) {
    return(data.frame())
  }
  
  # turn into data.frame
  df <- do.call(rbind, lapply(files, function(f) {
    data.frame(
      id       = f$id,
      filename = f$filename,
      purpose  = f$purpose,
      bytes    = f$bytes,
      created_at = as.POSIXct(f$created_at, origin = "1970-01-01"),
      stringsAsFactors = FALSE
    )
  }))
  
  df[order(df$created_at, decreasing = TRUE), ]
}

###################################################
# Deleting all files when done
###################################################
delete_file_from_openai <- function(
    file_id,
    api_key  = Sys.getenv("OPENAI_API_KEY"),
    api_base = "https://api.openai.com/v1"
) {
  req <- request(paste0(api_base, "/files/", file_id)) |>
    req_auth_bearer_token(api_key) |>
    req_method("DELETE") |>
    req_error(is_error = function(resp) FALSE)
  
  resp   <- req_perform(req)
  status <- resp_status(resp)
  
  if (status >= 400) {
    cat("Delete failed for", file_id, "with HTTP status:", status, "\n")
    cat("Response body:\n")
    cat(resp_body_string(resp), "\n")
    stop("Delete failed with HTTP ", status, call. = FALSE)
  }
  
  resp_body_json(resp)
}

#########################################################
# Read local code files and paste everything as as a txt
#########################################################
append_code_files <- function(folder, output_file = "combined_codes.txt") {
  
  # Vector of allowed file extensions
  exts <- c(
    "R", "r", "Rmd", "rmd",
    "py",
    "sas", "lst", "log",
    "sps", "spss", "spo", "spv",
    "do",
    "m",
    "inp", "mplus", "out", "gh5",
    "jl",
    "stan"
  )
  
  # Build regex pattern for file extensions
  pattern <- paste0(".*\\.(", paste(exts, collapse="|"), ")$", collapse = "")
  
  # List matching files
  files <- list.files(folder, pattern = pattern, ignore.case = TRUE, full.names = TRUE)
  
  if (length(files) == 0) {
    message("No code files found in the folder.")
    return(invisible(NULL))
  }
  
  # Open connection for writing output
  con <- file(output_file, open = "w", encoding = "UTF-8")
  
  for (f in files) {
    cat("---- FILE:", basename(f), "----\n", file = con, append = TRUE)
    
    # Safely read file lines
    lines <- tryCatch(
      readLines(f, warn = FALSE),
      error = function(e) paste("Could not read file:", f)
    )
    
    # Write file contents
    writeLines(lines, con)
    
    cat("\n\n", file = con, append = TRUE)
  }
  
  close(con)
  
  message("Combined code written to: ", output_file)
}
