# mediation_scanner.R
# Utility functions to scan text/code files for mediation analysis usage
# This is going to be a broad search (not exact)
mediation_patterns <- c(
  "mediation",
  "mediate\\s*\\(",
  "indirect effect",
  "indirect_effect",
  "bootstrap",
  
  # R packages / syntax
  "library\\s*\\(mediation\\)",
  "library\\s*\\(lavaan\\)",
  "lavaan\\s*\\(",
  "sem\\s*\\(",
  "processR",
  "lavaan::",
  
  # SPSS PROCESS macro style
  "PROCESS",
  "process macro",
  "PROCESS macro",
  "/model\\s*=\\s*4",
  "model\\s*4",
  "/model\\s*=",
  
  # variations of mediator-related vocab
  "mediat(e|or|ing)"
)

# Safely read a file as text
read_file_safe <- function(path, max_lines = 20000) {
  tryCatch(
    readLines(path, warn = FALSE, n = max_lines, encoding = "UTF-8"),
    error = function(e) character(0)
  )
}

# Scan one file for mediation content
scan_one_file <- function(path, patterns = mediation_patterns) {
  lines <- read_file_safe(path)
  
  if (length(lines) == 0) {
    return(NULL)
  }
  
  text_full <- paste(lines, collapse = "\n")
  
  # locate hits
  hits <- purrr::map_lgl(patterns, ~ stringr::str_detect(text_full, 
                                                         stringr::regex(.x, ignore_case = TRUE)))
  
  if (!any(hits)) {
    return(NULL)
  }
  
  matched_patterns <- patterns[hits]
  
  # extract snippet
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
