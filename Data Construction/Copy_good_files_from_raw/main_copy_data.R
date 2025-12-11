# Load library
library(dplyr)
library(purrr)
library(stringr)
library(tibble)

# Change the working directory 
# up to customization
setwd("C:/Users/chen/Downloads/process_mediation_studies")

# Read all folders
dirs <- sub("^\\./", "", 
            list.dirs(path = ".", recursive = FALSE))
dest_main <- "C:/Users/chen/Downloads/mediation_studies"

# Folder you want to scan
target_folder <- file.path(dirs[1])

# source the main function 
source("copy_files_to_newdir.R")
copy_files_to_newdir(target_folder, dest_main)
