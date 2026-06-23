#======================================================================
# Script name: 01_2_temporal_harmonization_meteo.R
# Goal(s): 
  # Elimination of duplicate records, based on decision making in temporal structure analysis and documentation of the decision making.
  # Aggregation of time stamps to 60 min intervals
  # temporal gap filling in between records based on the analysis of 01_1_temporal structure analysis
  # Documentation for each working step
# Author: Kai Albert Zwießler
# Date: 2026.06.15
# Input Data set:
  # United meteorological data separated by Source.Code and later ID column

# Output: 
  # Meteorological united data frame, containing the following actions:
    # Removed duplicate time stamps
    # Aggregated meteorological time stamps to 60 minutes intervals
    # gap filling for consistent temporal coverage, as preparation of flag assignments in the QC workflow.
    # Documentation for each working step
# =======================================

# ------------------------------------------------------------------------------
# Elimination of date - duplicates and Documentation
# ------------------------------------------------------------------------------
# Duplicate elimination based on the previous temporal structure analysis.
data_meteo <- data_meteo %>%
  distinct(Source.Code, Date, .keep_all = TRUE) # Check for doplicates in the two provided columns and keep all other records with .keep_all = TRUE
# Documentation
qc_logs[[length(qc_logs) + 1]] <- log_qc_decision(
  process_step = "Temporal harmonization",
  action = "manual_documentation",
  operator = "Kai Zwießler",
  device = "Meteorological Stations SENAMHI: Datasets_QUISOQUEPINA, SIBINACHOCHA_joined.xlsx",
  reason = paste("The temporal structure analysis identified duplicate timestamps.",
                 "A comparison of all meteorological measurement columns has shown that no deviations conflicts between the duplicate records.",
                 "The duplicates were therefore classified as redundant records and are removed prior to quality control. removed duplicates = 1438."
  ))



# ------------------------------------------------------------------------------
# Elimination of date - duplicates and Documentation
# ------------------------------------------------------------------------------