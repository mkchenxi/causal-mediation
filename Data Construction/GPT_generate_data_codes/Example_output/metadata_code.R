library(tibble)

mediation_metadata <- tibble::tibble(
  analysis_id = "M1",
  dataset_name = "m1_data (from `mplus_dataa2`)",
  treatment_var = "gcdomt1, gcpret1",
  mediator_vars = "gcdeft2",
  outcome_var = "gcprdvt2",
  control_vars = "gcprdvt1, gcsoct1, gccmpt1, gender, rtr_gend; clusters: target, rater",
  variable_descriptions = paste(
    "gcdomt1: group-mean-centered peer-rated dominance at T1;",
    "gcpret1: group-mean-centered peer-rated prestige at T1;",
    "gcdeft2: group-mean-centered peer-rated deference at T2 (mediator);",
    "gcprdvt2: group-mean-centered peer-rated social rank at T2 (DV);",
    "gcprdvt1: T1 social rank; gcsoct1: T1 social affinity; gccmpt1: T1 competence;",
    "gender: target gender; rtr_gend: rater gender; target/rater: cross-classified random intercepts."
  ),
  code_source_file = "Mplus mediation output file.out; data construction in 03 Scale Creation.Rmd, 04 Demographics and Descriptives.Rmd"
)

