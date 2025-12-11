# Load library
library(httr2)

folder <- "2nb6x"
api_key  <- Sys.getenv("OPENAI_API_KEY")  # set in .Renviron or environment
api_base <- "https://api.openai.com/v1"
model_id <- "gpt-4o-mini"  # or "gpt-5.1" if you have access

# Source basic functions 
source("general_prompts.R")

# Start the session
messages <- list(
  list(role = "system",
       content = "You are a statistical programming assistant who knows R, SAS, SPSS, Mplus, Python, and MATLAB."),
  list(role = "user",
       content = "Hi GPT, we will work on mediation analyses based on my project files.")
)
out <- gpt_chat(messages)
cat(out$reply$content)
messages <- out$messages   # keep extending this for future turns

# Paste all code files to txt
append_code_files(file.path(getwd(), folder), 
                  "all_codes.txt")
# Upload to GPT
upload_file_to_openai("all_codes.pdf")
file_ids   <- list_openai_files()$id

# Detect data files in the folder
source("find_data_files.R")
data_files <- detect_raw_data_files(file.path(getwd(), folder))

# Query GPT again for R codes and metadata of mediation data
source("code_generation_prompts.R")

# Generate prompts messages
messages <- create_mediation_messages(
  raw_files = data_files$raw_files,
  formats   = data_files$formats
)

# Get file ids
resp <- gpt_response_with_files(
  instructions = messages[[2]]$content,
  file_ids     = file_ids,
  model        = "gpt-5.1"
)

# Save codes
writeLines(resp$data_code, "data_code.R")
writeLines(resp$metadata_code, "metadata_code.R")

# Delete all files 
invisible(lapply(file_ids, delete_file_from_openai))
  
 