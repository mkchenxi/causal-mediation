# Overview of Data & Code Extraction Tools

This set of scripts provides a small toolkit for **scanning a project folder**, identifying **mediation-related code**, locating **data-construction scripts**, detecting **data files**, and **copying all relevant materials into a clean, consolidated directory**. The goal is to quickly gather all files needed to understand or reproduce the mediation analysis.

---

## Overall Workflow

1. **Select a project folder** containing a mediation analysis.
2. **Scan** the folder for:
   - Mediation scripts (R, Rmd, SPSS, Python, Mplus, etc.)
   - Data-cleaning and data-construction scripts
   - Raw or processed data files
3. **Copy** all identified files into a unified destination folder.
4. Use that folder for review, replication, archiving, or further automated processing.

The scripts are modular: each file handles one part of the workflow, and `main_copy_data.R` ties everything together.

---

## Script Summaries

### **1. `main_copy_data.R`**
The entry point of the workflow.  
Its purpose is to:
- Define the working directory.
- Select a project folder to scan.
- Call the main file-copying pipeline (`copy_files_to_newdir()`).
- Specify where the collected files should be saved.

---

### **2. `copy_files_to_newdir.R`**
The central orchestrator of the entire process.  
It:
- Scans the target project for relevant script files.
- Uses specialized scanners to detect mediation code, data-cleaning code, and data files.
- Collects all matched files.
- Copies them into a new folder named after the project.

This script coordinates all other helper scripts.

---

### **3. `mediation_scanner.R`**
Detects **mediation-related code** within script files.  
It searches for terms and patterns commonly associated with mediation analysis, such as:
- Mediation functions
- SEM/lavaan syntax
- PROCESS macro syntax
- Keywords related to indirect effects

Its role is simply to identify which code files appear to contain mediation analyses.

---

### **4. `data_construction_files_scanner.R`**
Detects **data-cleaning and data-construction scripts**.  
It searches for signs of data loading, merging, recoding, reshaping, and variable creation across languages (R, SPSS, Python, etc.).

Its job is to mark which script files help build the datasets used in the mediation analyses.

---

### **5. `data_files_scanner.R`**
Finds **raw or processed data files** inside the project folder.  
It recognizes many common data formats (CSV, RDS, SAV, DTA, Excel, etc.) and returns their paths.

This ensures that when copying a project, the relevant data files come along with the code.

---

## How the Pieces Fit Together

- `main_copy_data.R`  
  → chooses a project folder and calls the pipeline.

- `copy_files_to_newdir.R`  
  → gathers all information by calling:
  - `mediation_scanner.R`
  - `data_construction_files_scanner.R`
  - `data_files_scanner.R`

- The final output is a **clean folder** containing:
  - All mediation scripts
  - All data-construction scripts
  - All relevant data files  
  neatly copied and ready for inspection or replication.


