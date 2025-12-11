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