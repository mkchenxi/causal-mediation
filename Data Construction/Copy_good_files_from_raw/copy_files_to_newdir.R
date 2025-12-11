# This is the function for obtaining files and copy to a new dir
copy_files_to_newdir <- function(target_folder, dest_main) {
  
  #########################################################
  ## 2 - Scan for coding files
  #########################################################
  
  # Vector of relevant extensions (case-insensitive)
  relevant_ext <- c("R", "RMD", "RNW",  # R
                    "SPS",              # SPSS
                    "PY", "IPYNB",      # Python
                    "M", "OUT")         # Matlab, Mplus
  
  # List all files recursively
  all_files <- list.files(target_folder,
                          recursive = TRUE,
                          full.names = TRUE)
  
  # Get extension helper
  get_ext <- function(x) {
    tolower(tools::file_ext(x))
  }
  
  # Filter to relevant files
  relevant_files <- 
    all_files[get_ext(all_files) %in% tolower(relevant_ext)]
  
  # Inspect what we found
  if (length(relevant_files) == 0) {
    stop("No relevant script files found.")
  }
  
  #####################################################
  # 3 - Scan for mediation code files
  #####################################################
  
  # Load helper functions
  source("mediation_scanner.R")
  
  # Obtain files with mediation 
  mediation_hits_df <- purrr::map_dfr(relevant_files, 
                                      scan_one_file)
  
  # Scan for data construction files
  if (!exists("mediation_hits_df") || nrow(mediation_hits_df) == 0) {
    stop("No mediation scripts detected.")
  } 
  
  #####################################################
  # 4 - Scan for data cleaning files
  #####################################################
  # Load helper functions 
  source("data_construction_files_scanner.R")
  
  data_clean_hits_df <- purrr::map_dfr(
    relevant_files,
    scan_file_for_data_cleaning
  )
  
  #####################################################
  # 5 - Scan for all data files
  #####################################################
  # Load helper functions 
  source("data_files_scanner.R")
  
  # Find data files
  data_files_df <- find_data_files(target_folder)
  
  
  ####################################################
  # 6 - Copying all files to the new folder 
  ####################################################
  # ---- 1. Collect ALL file paths directly ----
  
  all_paths <- unique(c(
    mediation_hits_df$file_path,
    data_clean_hits_df$file_path,
    data_files_df$file_path
  ))
  
  # ---- 2. Define destination ----
  
  # Subfolder named after target_folder
  subfolder_name <- basename(target_folder)
  dest_sub <- file.path(dest_main, subfolder_name)
  dir.create(dest_sub, showWarnings = FALSE, recursive = TRUE)
  
  # ---- 3. Copy all files into one folder ----
  
  for (src in all_paths) {
    file.copy(src, file.path(dest_sub, basename(src)), overwrite = FALSE)
  }
  
  message("Copied ", length(all_paths), " unique files to: ", dest_sub)
  
}