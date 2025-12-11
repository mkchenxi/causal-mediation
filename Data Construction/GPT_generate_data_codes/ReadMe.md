# Overview of GPT-Based Code Generation Workflow

This folder contains a set of scripts designed to automate the process of:

1. **Collecting all code files** in a project folder.
2. **Uploading the combined code** to GPT via the OpenAI API.
3. **Scanning the project for raw data files** and identifying their formats.
4. **Generating R code** to reconstruct datasets used in mediation analyses.
5. **Generating metadata tables** describing each mediation analysis.
6. **Saving the generated R code back into the project folder.**

These scripts work together to enable fully automated dataset reconstruction and mediation-analysis documentation.

---

## Workflow Summary

The central workflow is:

1. Paste all code from a study/project folder into a single text (or PDF) file.
2. Upload that file to OpenAI.
3. Detect raw data files in the same folder.
4. Generate GPT prompts describing what information to extract.
5. Call the GPT Responses API with:
   - The instructions,
   - The uploaded project code,
   - The detected data files.
6. Retrieve:
   - R code that rebuilds analysis datasets, and  
   - A metadata table describing mediation analyses.
7. Write the generated R files back into the project folder.
8. Delete uploaded files on the OpenAI side for privacy.

The workflow resembles an automated “dataset reverse-engineering assistant.”

---

## Script Summaries

### **1. `main_generate_codes.R`**
The master script that coordinates the full GPT workflow.  
Its responsibilities include:  
- Loading API keys and model settings. :contentReference[oaicite:0]{index=0}  
- Starting a chat session with GPT.  
- Combining all code files in a selected folder into one file (`append_code_files()`).  
- Uploading that file to OpenAI and retrieving its `file_id`.  
- Detecting raw data files using `detect_raw_data_files()`.  
- Generating mediation-analysis prompts.  
- Calling `gpt_response_with_files()` to obtain R code and metadata.  
- Writing the results (`data_code.R`, `metadata_code.R`) into the project folder.  
- Cleaning up uploaded files from OpenAI.  

This script is the **entry point** for end-to-end reconstruction.

---

### **2. `code_generation_prompts.R`**
Defines the **prompt templates** used to instruct GPT.  
These templates specify:

- What to extract from the project code.  
- How to reconstruct mediation datasets.  
- What metadata to report about each mediation analysis.  
- How the output should be structured  
  (separate R code blocks for data construction and metadata creation).  

This script provides the intelligence behind the instructions passed to GPT. :contentReference[oaicite:1]{index=1}

---

### **3. `general_prompts.R`**
Provides core API helpers used across the workflow, including:

- `gpt_chat()` — basic chat-completion wrapper. :contentReference[oaicite:2]{index=2}  
- `upload_file_to_openai()` — uploads files to `/v1/files`.  
- `list_openai_files()` — lists uploaded files.  
- `delete_file_from_openai()` — deletes uploaded files.  
- `append_code_files()` — extracts and concatenates all code files in a folder into a single `.txt` file (later PDF-converted), ready for upload.  
- Environment variables and model IDs used throughout the pipeline.

This script contains the **core infrastructure** for interacting with OpenAI models.  

---

### **4. `find_data_files.R`**
Implements `detect_raw_data_files()`, which:

- Searches a folder for raw data files.  
- Recognizes a wide range of formats:  
  CSV, TSV, TXT, RDS, SAV, DTA, Excel, JSON, Feather, Parquet, SAS, SQL, compressed files, etc.  
- Outputs:
  - A list of raw filenames, and  
  - Their interpreted formats (e.g., CSV, SPSS, STATA).  

This information is embedded into the GPT prompt so the model knows **what raw data exist** and **how to write data-construction code** accordingly. :contentReference[oaicite:3]{index=3}

---

### **5. `gpt_response_with_files()` (inside `code_generation_prompts.R`)**
A specialized helper for the OpenAI **Responses API**.  
It sends:

- `instructions` (the long, detailed system-level mediation prompt)  
- Uploaded project files (`file_ids`)  
- A short user message  

and receives model outputs that contain the generated R code, metadata, and full explanation.  
This function abstracts away the low-level API calls required for structured responses. :contentReference[oaicite:4]{index=4}

---

## How the Pieces Fit Together

1. **`main_generate_codes.R`**  
   → central controller; runs everything end-to-end.

2. **`append_code_files()`**  
   → gathers all project code into one file for GPT.

3. **`upload_file_to_openai()` + `list_openai_files()`**  
   → provide GPT with the project code as a context file.

4. **`detect_raw_data_files()`**  
   → discovers raw data to guide reconstruction.

5. **`create_mediation_messages()` (from `code_generation_prompts.R`)**  
   → builds the instructions to GPT.

6. **`gpt_response_with_files()`**  
   → sends everything to GPT and retrieves structured output.

7. **Write results (`data_code.R`, `metadata_code.R`) into the project folder.**

8. **Clean up uploaded files** using `delete_file_from_openai()`.

Together, these scripts form a reproducible pipeline that lets GPT inspect a project, reverse-engineer mediation datasets, and produce ready-to-run R code plus documentation.

---

## Suggested Usage

1. Place raw data and analysis code into a folder (e.g., `"2nb6x"`).  
2. Run `main_generate_codes.R`.  
3. Retrieve:
   - `data_code.R` — R code that reconstructs datasets  
   - `metadata_code.R` — tibble describing mediation variables and models  
4. Review and run the generated code locally.


