# Helper to find raw data files and extensions
detect_raw_data_files <- function(
    dir = ".",
    recursive = FALSE,
    # A broad list of possible data extensions
    extensions = c(
      # Text-like formats
      "csv", "tsv", "txt", "dat", "data", "fwf",
      "json", "ndjson", "yaml", "yml", "xml",
      
      # R formats
      "rds", "rdata",
      
      # Stata formats
      "dta", "stb", "stc",
      
      # SPSS formats
      "sav", "zsav", "por",
      
      # SAS formats
      "sas7bdat", "xpt", "sd7", "sd2",
      
      # Excel / spreadsheet formats
      "xls", "xlsx", "xlsm", "ods",
      
      # Serialized binary / modern formats
      "feather", "parquet", "fst", "arrow", "ipc",
      
      # Database dumps
      "sqlite", "db", "db3",
      
      # Compressed variants (we handle them separately)
      "zip", "gz", "bz2", "tar"
    )
) {
  # Helper: extract extension(s)
  get_ext <- function(filename) {
    parts <- strsplit(filename, "\\.")[[1]]
    if (length(parts) <= 1) return("")
    tolower(tail(parts, 1))  # final extension only
  }
  
  # List files
  files <- list.files(dir, full.names = FALSE, recursive = recursive)
  
  # Extract extensions
  file_ext <- vapply(files, get_ext, character(1))
  
  # Detect compressed containers
  compressed <- file_ext %in% c("zip", "gz", "bz2", "tar")
  
  # If compressed, try to determine underlying file type from name
  # E.g., "survey.csv.gz" → extension should be "csv"
  get_underlying_ext <- function(filename) {
    name <- tools::file_path_sans_ext(filename)
    ext <- get_ext(name)
    tolower(ext)
  }
  
  underlying_ext <- ifelse(compressed,
                           vapply(files, get_underlying_ext, character(1)),
                           file_ext)
  
  # Match against known data formats
  sel <- underlying_ext %in% tolower(extensions)
  
  data_files <- files[sel]
  data_ext   <- underlying_ext[sel]
  
  # Map extensions to friendly format names
  format_map <- list(
    csv = "CSV",
    tsv = "TSV",
    txt = "TXT",
    dat = "DAT",
    data = "DATA",
    fwf = "FWF",
    json = "JSON",
    ndjson = "NDJSON",
    yaml = "YAML",
    yml = "YAML",
    xml = "XML",
    
    rds = "RDS",
    rdata = "RData",
    
    dta = "STATA",
    stb = "STATA",
    stc = "STATA",
    
    sav = "SPSS",
    zsav = "SPSS",
    por = "SPSS",
    
    sas7bdat = "SAS",
    xpt = "SAS-XPT",
    sd7 = "SAS",
    sd2 = "SAS",
    
    xls = "XLS",
    xlsx = "XLSX",
    xlsm = "XLSM",
    ods = "ODS",
    
    feather = "FEATHER",
    parquet = "PARQUET",
    fst = "FST",
    arrow = "ARROW",
    ipc = "ARROW",
    
    sqlite = "SQLITE",
    db = "DATABASE",
    db3 = "DATABASE"
  )
  
  `%||%` <- function(a, b) if (!is.null(a)) a else b
  
  formats <- sapply(data_ext, function(e) {
    format_map[[e]] %||% toupper(e)
  })
  
  list(
    raw_files = data_files,
    formats   = formats
  )
}
