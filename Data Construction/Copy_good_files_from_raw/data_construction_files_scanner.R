# This is a broad search of files that do data cleaning

# This should match most of actions; expanded if needed. 
data_cleaning_patterns <- c(
  # ---- R data loading ----
  "read\\.csv\\s*\\(",
  "read_csv\\s*\\(",
  "read\\.table\\s*\\(",
  "read_table\\s*\\(",
  "readRDS\\s*\\(",
  "read\\.rds\\s*\\(",
  "read_sav\\s*\\(",
  "read\\.sav\\s*\\(",
  "read_dta\\s*\\(",
  "read\\.dta\\s*\\(",
  "readxl::read_",     # read_excel etc.
  "vroom::vroom",
  
  # ---- R data manipulation / cleaning (dplyr, base) ----
  "mutate\\s*\\(",
  "transmute\\s*\\(",
  "filter\\s*\\(",
  "select\\s*\\(",
  "rename\\s*\\(",
  "arrange\\s*\\(",
  "left_join\\s*\\(",
  "right_join\\s*\\(",
  "inner_join\\s*\\(",
  "full_join\\s*\\(",
  "group_by\\s*\\(",
  "summarise\\s*\\(",
  "summarize\\s*\\(",
  "pivot_longer\\s*\\(",
  "pivot_wider\\s*\\(",
  "spread\\s*\\(",
  "gather\\s*\\(",
  "merge\\s*\\(",
  "within\\s*\\(",
  "transform\\s*\\(",
  "scale\\s*\\(",
  "ifelse\\s*\\(",
  
  # ---- SPSS: data loading / transforming ----
  "GET FILE\\s*=",
  "GET DATA",
  "DATA LIST",
  "DATASET NAME",
  "DATASET ACTIVATE",
  "EXECUTE\\.",
  "COMPUTE\\s+",
  "RECODE\\s+",
  "IF\\s+\\(",
  "DO IF",
  "ELSE IF",
  "VALUE LABELS",
  "VARIABLE LABELS",
  
  # ---- Python (pandas) data loading / cleaning ----
  "pd\\.read_csv\\s*\\(",
  "pd\\.read_table\\s*\\(",
  "pd\\.read_spss\\s*\\(",
  "pd\\.read_stata\\s*\\(",
  "pd\\.read_excel\\s*\\(",
  "dropna\\s*\\(",
  "fillna\\s*\\(",
  "astype\\s*\\(",
  "merge\\s*\\(",
  "join\\s*\\(",
  "groupby\\s*\\(",
  "pivot_table\\s*\\(",
  "\\.loc\\[",
  "\\.iloc\\[",
  "\\[.*\\]\\s*=",        # df['new'] = ... (very broad)
  
  # ---- Matlab: loading and manipulating ----
  "load\\s*\\(",
  "readtable\\s*\\(",
  "xlsread\\s*\\(",
  "writetable\\s*\\(",
  "table\\s*\\(",
  "dataset\\s*\\("       # old stats toolbox
)

# This function scans files for data cleaning 
scan_file_for_data_cleaning <- function(path, patterns = data_cleaning_patterns) {
  lines <- read_file_safe(path)
  if (length(lines) == 0) return(NULL)
  
  text_full <- paste(lines, collapse = "\n")
  
  hits <- purrr::map_lgl(
    patterns,
    ~ stringr::str_detect(text_full, stringr::regex(.x, ignore_case = TRUE))
  )
  
  if (!any(hits)) return(NULL)
  
  matched_patterns <- patterns[hits]
  
  # get a small snippet around the first hit
  snippet <- NULL
  for (pat in matched_patterns) {
    idx <- which(stringr::str_detect(lines, stringr::regex(pat, ignore_case = TRUE)))[1]
    if (!is.na(idx)) {
      from <- max(1, idx - 2)
      to   <- min(length(lines), idx + 2)
      snippet <- paste(lines[from:to], collapse = "\n")
      break
    }
  }
  
  tibble::tibble(
    file_path        = path,
    matched_patterns = paste(matched_patterns, collapse = "; "),
    snippet          = snippet
  )
}
