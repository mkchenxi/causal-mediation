1. **List of mediation analyses detected**

- **M1** – Multilevel mediation of T1 dominance and prestige on T2 social rank via T2 deference (peer-reported, group-mean centered), estimated in Mplus using `mplus_dataa2.csv` (constructed from the main MBA dataset `both_dataa`).  

No other mediation analyses are implemented in the R code files you provided. The Read Me explicitly states that the “deference mediation model was conducted in Mplus,” and the Mplus `.out` file is the only place where a mediation model is actually specified (with paths `gcdomt1 → gcdeft2 → gcprdvt2` and `gcpret1 → gcdeft2 → gcprdvt2`). All R models are regression / multilevel models without mediators in the outcome model.

---

### Details for M1

**analysis_id:** M1  

**Source of mediation model:**  
- `Mplus mediation output file.out` (Mplus syntax and output)  
- Underlying data come from the R-constructed MBA dataset `both_dataa`, exported to `mplus_dataa2.csv`.

**1. Model structure (from Mplus syntax)**

From the `MODEL:` section of the Mplus input:

```mplus
%WITHIN%
gcprdvt2 on gcdomt1(c1);
gcprdvt2 on gcpret1(c2);
gcprdvt2 on gcprdvt1 gccmpt1 gcprdvt1;
gcdeft2 on gcdomt1(Sa1);
gcdeft2 on gcpret1(Sa2);
gcdeft2 on gcsoct1 gccmpt1 gcprdvt1;
gcprdvt2 on gcdeft2(Sb);

%BETWEEN target%
gcprdvt2 on gender;

%BETWEEN rater%
gcprdvt2 on rtr_gend;

MODEL CONSTRAINT:
NEW(def_ind_dom);
def_ind_dom = Sa1*Sb;
NEW(def_ind_pre);
def_ind_pre = Sa2*Sb;
NEW(tot_dom);
tot_dom = def_ind_dom + c1;
NEW(tot_pre);
tot_pre = def_ind_pre + c2;
```

This is a **2-1-1 multilevel mediation** with cross-classified random effects (targets and raters).

**2. Variables for M1**

- `dataset_name`: `both_dataa` (R side) → exported as `mplus_dataa2.csv` (Mplus side)

- **Treatment variables (X):**
  - `gcdomt1` – group-mean centered peer-rated dominance at Time 1  
  - `gcpret1` – group-mean centered peer-rated prestige at Time 1  

- **Mediator (M):**
  - `gcdeft2` – group-mean centered peer-rated deference at Time 2  

- **Outcome (Y):**
  - `gcprdvt2` – group-mean centered peer-rated social rank at Time 2  

- **Baseline outcome control:**
  - `gcprdvt1` – group-mean centered peer-rated social rank at Time 1  

- **Additional within-level controls:**
  - `gccmpt1` – group-mean centered peer-rated competence at Time 1  
  - `gcsoct1` – group-mean centered peer-rated social affinity at Time 1  

- **Between-level controls:**
  - `gender` – target gender (between-target)  
  - `rtr_gend` – rater gender (between-rater; called `rater_gender` in R)  

- **Cluster variables:**
  - `target` – target ID  
  - `rater` – rater ID  

**Short descriptions (from Methods + code comments):**

- `gcdomt1`: Peer-reported dominance at T1, group-mean centered within project group.  
- `gcpret1`: Peer-reported prestige at T1, group-mean centered within project group.  
- `gcdeft2`: Peer-reported deference at T2, group-mean centered within project group.  
- `gcprdvt1`: Peer-reported social rank at T1, group-mean centered within project group.  
- `gcprdvt2`: Peer-reported social rank at T2, group-mean centered within project group.  
- `gccmpt1`: Peer-reported competence at T1, group-mean centered within project group.  
- `gcsoct1`: Peer-reported social affinity at T1, group-mean centered within project group.  
- `gender`: Target gender (0/1 in Mplus; factor in R).  
- `rtr_gend` / `rater_gender`: Rater gender (0/1 in Mplus; factor in R).  

**code_source_file:**  
- R-side dataset construction: primarily `02 Factor Analysis.Rmd`, `03 Scale Creation.Rmd`, `04 Demographics and Descriptives.Rmd`.  
- Mediation model itself: `Mplus mediation output file.out`.

---

### 2. How the mediation dataset is constructed (M1)

The Mplus file reads:

```mplus
DATA: FILE is "/Users/kaylene/Documents/kaylene/mplus_dataa2.csv"
```

That CSV is not created in the snippets you provided, but we can infer its structure from:

- The `VARIABLE: NAMES ARE ...` list in the Mplus file.
- The R code that creates all the `gc*` variables and IDs in `03 Scale Creation.Rmd` and `04 Demographics and Descriptives.Rmd`.

Key steps in R that lead to the mediation variables:

1. **Load raw MBA data**  
   - In `02 Factor Analysis.Rmd`:
     ```r
     both_dataa <- read.csv(here('Raw Data', 'full_mba_data.csv'))
     ```
   - This is the main MBA dataset (not the pilot). It contains peer ratings, self-reports, IDs, etc.

2. **Create peer-report scales (dominance, prestige, social rank, deference, competence, social affinity)**  
   - In `03 Scale Creation.Rmd`:
     - Dominance T1/T2: `peerdomt1`, `peerdomt2` from JC items 27, 29, 31, 33.  
     - Prestige T1/T2: `peerpret1`, `peerpret2` from JC items 37–39.  
     - Social rank T1/T2: `peerdv_t1`, `peerdv_t2` from `dv1_t1` & `dv5_t1` (and T2 analogues).  
     - Deference T1/T2: `peerdefer_t1`, `peerdefer_t2` already present in `both_dataa`.  
     - Competence & social affinity: `peercontri_t1/t2`, `peersocial_t1/t2` already present.

3. **Group-mean centering at the rater–target level**  
   - In `03 Scale Creation.Rmd`:
     ```r
     both_dataa <- both_dataa %>% 
       group_by(groupnum) %>% 
       mutate(
         groupmeanpeerdv_t1 = mean(peerdv_t1, na.rm = T),
         groupmeanpeerdv_t2 = mean(peerdv_t2, na.rm = T),
         groupmeanpre_t1   = mean(peerpret1, na.rm = T),
         groupmeanpre_t2   = mean(peerpret2, na.rm = T),
         groupmeandom_t1   = mean(peerdomt1, na.rm = T),
         groupmeandom_t2   = mean(peerdomt2, na.rm = T),
         groupmeansocial_t1 = mean(peersocial_t1, na.rm = T),
         groupmeansocial_t2 = mean(peersocial_t2, na.rm = T),
         groupmeancontri_t1 = mean(peercontri_t1, na.rm = T),
         groupmeancontri_t2 = mean(peercontri_t2, na.rm = T),
         groupmeandef_t1    = mean(peerdefer_t1, na.rm = T),
         groupmeandef_t2    = mean(peerdefer_t2, na.rm = T),
       ) %>% 
       ungroup() %>% 
       mutate(
         gcpeerdv_t1 = peerdv_t1 - groupmeanpeerdv_t1,
         gcpeerdv_t2 = peerdv_t2 - groupmeanpeerdv_t2,
         gcpre_t1    = peerpret1 - groupmeanpre_t1,
         gcpre_t2    = peerpret2 - groupmeanpre_t2,
         gcdom_t1    = peerdomt1 - groupmeandom_t1,
         gcdom_t2    = peerdomt2 - groupmeandom_t2,
         gcsocial_t1 = peersocial_t1 - groupmeansocial_t1,
         gcsocial_t2 = peersocial_t2 - groupmeansocial_t2,
         gccontri_t1 = peercontri_t1 - groupmeancontri_t1,
         gccontri_t2 = peercontri_t2 - groupmeancontri_t2,
         gcdef_t1    = peerdefer_t1 - groupmeandef_t1,
         gcdef_t2    = peerdefer_t2 - groupmeandef_t2
       )
     ```
   - These correspond to the Mplus variables:
     - `gcprdvt1` ↔ `gcpeerdv_t1`
     - `gcprdvt2` ↔ `gcpeerdv_t2`
     - `gcdomt1`  ↔ `gcdom_t1`
     - `gcpret1`  ↔ `gcpre_t1`
     - `gcsoct1`  ↔ `gcsocial_t1`
     - `gccmpt1`  ↔ `gccontri_t1` (competence)
     - `gcdeft2`  ↔ `gcdef_t2`

4. **Target-level group-mean centering (not directly used in Mplus mediation)**  
   - Also in `03 Scale Creation.Rmd`, they create `group_dv_t1`, `group_dom_t1`, etc., and then `gcgroup*` variables. These are used in self-report models and SRM, not in the Mplus mediation.

5. **Restrict to the “correct” social rank measure (studynum == 2)**  
   - In `04 Demographics and Descriptives.Rmd`:
     ```r
     dataa <- both_dataa %>% 
       filter(studynum == 2)
     ```
   - The Mplus file uses `studynum` in the `NAMES ARE` list but does not filter on it; the filtering likely happened before exporting `mplus_dataa2.csv`. For reconstruction, we will mirror the paper’s main-analyses restriction (`studynum == 2`).

6. **Gender variables**  
   - `gender` and `rater_gender` are present in `both_dataa` (see multiple models in `06 Self-Report Models.Rmd`, `07 TIPI Analyses.Rmd`, etc.).  
   - In Mplus, they are coded as 0/1 (`GENDER`, `RTR_GEND`).

7. **Export to Mplus**  
   - Not shown explicitly, but the Mplus `NAMES ARE` list matches the variables in `both_dataa` plus the `gc*` variables. The CSV `mplus_dataa2.csv` is therefore a cleaned/exported version of `both_dataa` (likely filtered to `studynum == 2` and with some renaming).

---

### 3. R code to reconstruct mediation datasets

Below is ready-to-run R code that:

- Loads raw data.
- Reconstructs `both_dataa` with all relevant variables for the mediation.
- Creates the group-mean-centered variables used in the Mplus mediation.
- Produces a dataset `mplus_dataa2` that matches the Mplus `USEVARIABLES` set as closely as possible, assuming the raw MBA file is named `full_mba_data.csv` in `Raw Data/`.

Note: You also provided pilot data files (`pilot_raw_data_mba_osf.csv`, `pilot_raw_data_undergrad_osf.csv`), but these are not used in the mediation; they are only used in `01 Pilot Study Analysis.Rmd`. I include only the MBA mediation dataset here.

---

### R code to reconstruct mediation datasets

```r
# ---- Setup ----
library(tidyverse)
library(here)

# ---- M1: Reconstruct both_dataa and mediation dataset (mplus_dataa2) ----

# 1. Load raw MBA data
# Assumes the raw MBA data file is in "Raw Data/full_mba_data.csv"
both_dataa <- read.csv(here("Raw Data", "full_mba_data.csv"),
                       stringsAsFactors = FALSE)

# 2. (Optional but recommended) ensure lower-case names to match Rmd code style
names(both_dataa) <- tolower(names(both_dataa))

# 3. Create peer-report scales used in mediation and other models
#    - Dominance (peerdomt1, peerdomt2)
#    - Prestige (peerpret1, peerpret2)
#    - Social rank (peerdv_t1, peerdv_t2)
#    - Full social rank (fullpeerdv_t1, fullpeerdv_t2) – not needed for Mplus but used elsewhere
#    - Deference (peerdefer_t1, peerdefer_t2) – assumed present in raw data
#    - Competence (peercontri_t1, peercontri_t2) – assumed present
#    - Social affinity (peersocial_t1, peersocial_t2) – assumed present

## Dominance scales (JC items 27, 29, 31, 33)
both_dataa$peerdomt1 <- rowMeans(
  both_dataa[, c("jc27t1", "jc29t1", "jc31t1", "jc33t1")],
  na.rm = TRUE
)

both_dataa$peerdomt2 <- rowMeans(
  both_dataa[, c("jc27t2", "jc29t2", "jc31t2", "jc33t2")],
  na.rm = TRUE
)

## Prestige scales (JC items 37, 38, 39)
both_dataa$peerpret1 <- rowMeans(
  both_dataa[, c("jc37t1", "jc38t1", "jc39t1")],
  na.rm = TRUE
)

both_dataa$peerpret2 <- rowMeans(
  both_dataa[, c("jc37t2", "jc38t2", "jc39t2")],
  na.rm = TRUE
)

## Social rank (DV) – 2-item scale (dv1 & dv5)
both_dataa$peerdv_t1 <- rowMeans(
  both_dataa[, c("dv1_t1", "dv5_t1")],
  na.rm = TRUE
)

both_dataa$peerdv_t2 <- rowMeans(
  both_dataa[, c("dv1_t2", "dv5_t2")],
  na.rm = TRUE
)

## Full 6-item social rank (for completeness; not needed for Mplus mediation)
both_dataa$fullpeerdv_t1 <- rowMeans(
  both_dataa[, paste0("dv", 1:6, "_t1")],
  na.rm = TRUE
)

both_dataa$fullpeerdv_t2 <- rowMeans(
  both_dataa[, paste0("dv", 1:6, "_t2")],
  na.rm = TRUE
)

# 4. Group-mean centering at the rater–target level (per 03 Scale Creation.Rmd)

both_dataa <- both_dataa %>%
  group_by(groupnum) %>%
  mutate(
    # group means
    groupmeanpeerdv_t1 = mean(peerdv_t1, na.rm = TRUE),
    groupmeanpeerdv_t2 = mean(peerdv_t2, na.rm = TRUE),
    groupmeanpre_t1    = mean(peerpret1, na.rm = TRUE),
    groupmeanpre_t2    = mean(peerpret2, na.rm = TRUE),
    groupmeandom_t1    = mean(peerdomt1, na.rm = TRUE),
    groupmeandom_t2    = mean(peerdomt2, na.rm = TRUE),
    groupmeansocial_t1 = mean(peersocial_t1, na.rm = TRUE),
    groupmeansocial_t2 = mean(peersocial_t2, na.rm = TRUE),
    groupmeancontri_t1 = mean(peercontri_t1, na.rm = TRUE),
    groupmeancontri_t2 = mean(peercontri_t2, na.rm = TRUE),
    groupmeandef_t1    = mean(peerdefer_t1, na.rm = TRUE),
    groupmeandef_t2    = mean(peerdefer_t2, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  mutate(
    # group-mean centered variables
    gcpeerdv_t1 = peerdv_t1 - groupmeanpeerdv_t1,
    gcpeerdv_t2 = peerdv_t2 - groupmeanpeerdv_t2,
    gcpre_t1    = peerpret1 - groupmeanpre_t1,
    gcpre_t2    = peerpret2 - groupmeanpre_t2,
    gcdom_t1    = peerdomt1 - groupmeandom_t1,
    gcdom_t2    = peerdomt2 - groupmeandom_t2,
    gcsocial_t1 = peersocial_t1 - groupmeansocial_t1,
    gcsocial_t2 = peersocial_t2 - groupmeansocial_t2,
    gccontri_t1 = peercontri_t1 - groupmeancontri_t1,
    gccontri_t2 = peercontri_t2 - groupmeancontri_t2,
    gcdef_t1    = peerdefer_t1 - groupmeandef_t1,
    gcdef_t2    = peerdefer_t2 - groupmeandef_t2
  )

# 5. (Optional) restrict to the “correct” social rank measure (studynum == 2)
#    This mirrors the main analyses in the paper.
both_dataa <- both_dataa %>%
  filter(studynum == 2)

# 6. Ensure gender variables are in the right format
#    In R, gender and rater_gender are factors; in Mplus they are 0/1.
#    Here we keep them as-is; if you want exact 0/1 coding, recode explicitly.

# Example recoding (if needed):
# both_dataa <- both_dataa %>%
#   mutate(
#     gender_num      = ifelse(gender == "Male", 0, 1),
#     rtr_gend_num    = ifelse(rater_gender == "Male", 0, 1)
#   )

# 7. Construct the Mplus mediation dataset (mplus_dataa2)
#    We match the USEVARIABLES list in the Mplus file as closely as possible.

mplus_dataa2 <- both_dataa %>%
  transmute(
    # cluster variables
    target,
    rater,
    grpnum      = groupnum,
    # within-level variables used in USEVARIABLES
    gcprdvt2    = gcpeerdv_t2,
    gcprdvt1    = gcpeerdv_t1,
    gcdomt1     = gcdom_t1,
    gcpret1     = gcpre_t1,
    gcsoct1     = gcsocial_t1,
    gccmpt1     = gccontri_t1,
    gcdeft2     = gcdef_t2,
    # between-level variables
    gender      = gender,
    rtr_gend    = rater_gender,
    # keep studynum and other IDs if desired
    studynum
  )

# If you want to write this out exactly as Mplus used it:
# write.csv(mplus_dataa2, "mplus_dataa2.csv", row.names = FALSE)
```

---

### 4. Mediation metadata table

#### Markdown table

```markdown
| analysis_id | dataset_name | treatment_var                 | mediator_vars | outcome_var | control_vars                                                                 | variable_descriptions                                                                                                                                                                                                                                      | code_source_file                     |
|------------|--------------|-------------------------------|---------------|-------------|------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------|
| M1         | both_dataa   | gcdomt1 (gcdom_t1), gcpret1 (gcpre_t1) | gcdeft2      | gcprdvt2    | Within: gcprdvt1, gccmpt1, gcsoct1; Between: gender, rtr_gend; clusters: target, rater | gcdomt1/gcdom_t1: group-mean centered peer-rated dominance at T1; gcpret1/gcpre_t1: group-mean centered peer-rated prestige at T1; gcdeft2: group-mean centered peer-rated deference at T2; gcprdvt1/2: group-mean centered peer-rated social rank at T1/T2; gccmpt1: group-mean centered peer-rated competence at T1; gcsoct1: group-mean centered peer-rated social affinity at T1; gender: target gender; rtr_gend: rater gender; target/rater: clustering IDs. | Mplus mediation output file.out (model); 02 Factor Analysis.Rmd, 03 Scale Creation.Rmd, 04 Demographics and Descriptives.Rmd (dataset construction) |
```

#### R code to define `mediation_metadata` tibble

```r
library(tibble)

mediation_metadata <- tribble(
  ~analysis_id, ~dataset_name, ~treatment_var,                                  ~mediator_vars, ~outcome_var, ~control_vars,                                                                                          ~variable_descriptions,                                                                                                                                                                                                                                                                                                                                                                      ~code_source_file,
  "M1",        "both_dataa",  "gcdomt1 (gcdom_t1), gcpret1 (gcpre_t1)",        "gcdeft2",      "gcprdvt2",   "Within: gcprdvt1, gccmpt1, gcsoct1; Between: gender, rtr_gend; clusters: target, rater",
  "gcdomt1/gcdom_t1: group-mean centered peer-rated dominance at T1; gcpret1/gcpre_t1: group-mean centered peer-rated prestige at T1; gcdeft2: group-mean centered peer-rated deference at T2; gcprdvt1/2: group-mean centered peer-rated social rank at T1/T2; gccmpt1: group-mean centered peer-rated competence at T1; gcsoct1: group-mean centered peer-rated social affinity at T1; gender: target gender; rtr_gend: rater gender; target/rater: clustering IDs.",
  "Mplus mediation output file.out (model); 02 Factor Analysis.Rmd, 03 Scale Creation.Rmd, 04 Demographics and Descriptives.Rmd (dataset construction)"
)
```

This completes the mediation-dataset reconstruction for the analyses present in your code.
