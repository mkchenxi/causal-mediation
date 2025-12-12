Below is the **fully generalized prompt** updated with your new requirement:

* If raw data needed for a mediation dataset are **not available**, GPT should **return `NULL` for that dataset’s R-construction code**.
* Step 6 explicitly accounts for non-available raw data.
* A placeholder is included where you will insert the list of raw data files you have.

---

# **Generalized Prompt (Final Version — No Mplus, Single Code File Input, Raw Data Inventory Placeholder, NULL output when data unavailable)**

You are an expert in statistical programming (R, Python, Stata), mediation analysis, data reconstruction, and code-base forensics.
I will upload a **single integrated text file (.txt)** that contains all project code (merged scripts).
I will also provide a **list of all raw data files I have access to**, including filenames and formats.

**RAW DATA FILES I HAVE:**

> *[Insert list of raw data files here — filenames and formats]*

Your tasks are to:

1. Detect all mediation analyses in the project
2. Determine whether their datasets can be reconstructed from the raw data *I actually possess*
3. Produce R code to reconstruct the mediation datasets **when possible**, or `NULL` when not
4. Produce metadata describing all mediation models
5. Produce R code to generate a metadata tibble

Follow the workflow below.

---

## **1. Read and interpret the uploaded project code**

You will receive one `.txt` file that contains all source code from the project.
From this text:

1. Parse all scripts, functions, data wrangling steps, and modeling code.
2. Identify **every mediation analysis**, including:

   * Simple / parallel / serial mediation
   * Moderated mediation
   * Longitudinal mediation
   * Multilevel mediation implemented in R / Python / Stata
3. For each mediation model, extract:

   * Predictor(s)
   * Mediator(s)
   * Outcome(s)
   * Control variables
   * Clustering or grouping structure (if any)
   * Dataset name used for estimation
   * Any variable transformations (centering, scaling, composite construction, etc.)
4. Assign each mediation model a unique ID:

   * `"M1"`, `"M2"`, `"M3"`, etc.

Output this information in a section titled:

### **“List of mediation analyses detected.”**

---

## **2. Determine whether each mediation dataset can be reconstructed**

Using the raw data files I provide (listed above):

1. For each mediation dataset:

   * Trace the variables back through the code to determine which raw or intermediate files they come from.
   * Determine whether **all required raw variables** exist in the files I possess.

2. Classify reconstruction feasibility:

   * **Fully reconstructible** – all necessary raw data files exist and all variable transformations are documented.
   * **Partially reconstructible** – some data or steps are missing; reconstruct what can be reconstructed and document assumptions.
   * **Not reconstructible** – essential raw data are not available.

3. If **not reconstructible**, then:

   * The R code output for constructing that dataset must be **`NULL`**.
   * Metadata must explicitly state that reconstruction was not possible and why.

---

## **3. Produce R code to reconstruct all reconstructible mediation datasets**

For each mediation model:

* If reconstruction is **fully or partially possible**, produce **clean, standalone R code** that:

  * Loads necessary packages
  * Reads in all raw data files (using the filenames and formats I provide)
  * Performs all data cleaning, merging, recoding, and transformation steps required
  * Constructs a final dataset named:

    * `m1_data`, `m2_data`, etc.

* If reconstruction is **not possible**, output:

```r
m1_data <- NULL
```

and annotate (in comments) which raw files or steps were missing.

Present all reconstruction code under the header:

### **“R code to reconstruct mediation datasets.”**

---

## **4. Construct a mediation metadata table**

Create a **markdown table** with one row per mediation model, including:

* `analysis_id`
* `dataset_name`
* `treatment_var`
* `mediator_vars`
* `outcome_var`
* `control_vars`
* `variable_descriptions`
* `reconstruction_status` – `"full"`, `"partial"`, or `"not possible"`
* `reason_if_not_reconstructible`
* `code_source_location` – where in the `.txt` file the model appeared

Present under:

### **“Metadata summarizing the mediation analyses.”**

---

## **5. Generate R code to build a metadata tibble**

Write an R code block that constructs a tibble:

```r
mediation_metadata <- tibble::tibble(
  analysis_id = ...,
  dataset_name = ...,
  treatment_var = ...,
  mediator_vars = ...,
  outcome_var = ...,
  control_vars = ...,
  variable_descriptions = ...,
  reconstruction_status = ...,
  reason_if_not_reconstructible = ...,
  code_source_location = ...
)
```

Present this in a fenced R block under:

### **“R code to define `mediation_metadata` tibble.”**

---

## **6. Handling missing, ambiguous, or unavailable data**

If the project code references:

* A dataset not included in the files I have
* A variable that cannot be derived from any raw data available
* A preprocessing script whose inputs are unavailable

Then:

1. Clearly state what information is missing.
2. Explain why reconstruction is impossible.
3. For that mediation model, return:

```r
mX_data <- NULL
```

4. Fill the metadata fields with:

   * `reconstruction_status = "not possible"`
   * `reason_if_not_reconstructible` describing the missing elements

If reconstruction is **partially possible** (some variables missing but dataset can be partially created):

* Provide R code that constructs what *can* be built, and document assumptions.

---

## **7. Final Output Format (must follow exactly)**

Your final answer must contain these four sections in order:

1. **List of mediation analyses detected**
2. **R code to reconstruct mediation datasets**
3. **Metadata summarizing the mediation analyses**
4. **R code to define `mediation_metadata` tibble**

---

If you'd like, I can also produce:

* A shorter version
* A version optimized for massive codebases (10,000+ lines)
* A version specialized for R-only projects

Just let me know!
