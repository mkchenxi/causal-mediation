# find possible data files

data_extensions <- c(
  # Plain text data
  "csv", "tsv", "txt", "dat",
  
  # Excel
  "xls", "xlsx", "xlsm", "xlsb",
  
  # R file formats
  "rds", "rdata", "rda",
  
  # SPSS formats
  "sav", "por",
  
  # Stata
  "dta",
  
  # SAS
  "sas7bdat",
  
  # Python
  "pkl", "pickle",
  
  # JSON / structured text
  "json", "yaml", "yml",
  
  # Feather / Parquet / columnar formats
  "feather", "fst", "parquet",
  
  # MATLAB
  "mat",
  
  # SQLite / database dumps
  "sqlite", "db", "sql",
  
  # Misc possibly tabular formats
  "ods"
)

# a function to find the files with the extensions
find_data_files <- function(target_folder, extensions = data_extensions) {
  
  all_files <- list.files(
    target_folder,
    recursive = TRUE,
    full.names = TRUE
  )
  
  get_ext <- function(x) tolower(tools::file_ext(x))
  
  matches <- all_files[get_ext(all_files) %in% tolower(extensions)]
  
  if (length(matches) == 0) {
    message("No data files detected using known extensions.")
    return(tibble::tibble())
  }
  
  tibble::tibble(
    file_path   = matches,
    file_name   = basename(matches),
    extension   = get_ext(matches),
    rel_path    = sub(paste0("^", target_folder, "/?"), "", matches)
  )
}
