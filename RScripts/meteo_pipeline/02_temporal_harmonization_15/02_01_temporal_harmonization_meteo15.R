#======================================================================
# Script name: 02_01_temporal_harmonization_meteo15.R
# Goal(s): 
  # Elimination of duplicate records in master data frame, based on decision making in 01_01 temporal structure analysis and documentation of the decision making.
  # Documentation of Temporal gap filling result for 15 min data sheet 10_QORIKALIS_18_08_2025.csv based on the analysis of 01_01_temporal structure analysis
  # Documentation of each decision making step
# Author: Kai Albert Zwießler
# Date: 2026.06.15
# Input Data set:
  # Standardized meteorological data from the load_and_standardize_meteo workflow
  # => filtered 10_QORIKALIS_18_08_2025.csv 15 min temporal resolution data
# Output: 
  # QK15 data frame, named data_meteo15_harmonized
# =======================================

# ------------------------------------------------------------------------------
# Elimination of date - duplicates and Documentation
# ------------------------------------------------------------------------------
# Duplicate elimination on basis of individual files, based on the discoveries made in temporal structure analysis.
data_meteo_standardized <- data_meteo_standardized %>%
  distinct(Source.Code, Date, .keep_all = TRUE) # Check for duplicates in the two provided columns and keep all other records with .keep_all = TRUE

# Duplicate elimination on basis of individual files, based on the discoveries made in temporal structure analysis.
data_meteo_standardized <- data_meteo_standardized %>%
  distinct(ID, Date, .keep_all = TRUE)

# ====================================================
# 15 - minute workflow for 10_QORIKALIS_18_08_2025.csv
# ====================================================

# Extraction of data 10_QORIKALIS_18_08_2025.csv
data_meteo15_standardized <- data_meteo_standardized %>%
  filter(Source.Code == "10_QORIKALIS_18_08_2025.csv")

# ------------------------------------------------------------------------------
# Complete missing time steps for 10_QORIKALIS_18_08_2025.csv
# ------------------------------------------------------------------------------

# RESULT:
# Temporal completeness check for 10_QORIKALIS_18_08_2025.csv
# No missing 15-minute time steps were detected within the observation period.
# Therefore no temporal completion was required prior to aggregation.
# The partial data sheet is now approved to enter QC-15 workflows.

# ------------------------------------------------------------------------------
# Documentation
# ------------------------------------------------------------------------------
# duplicate decision file based
qc_logs[[length(qc_logs) + 1]] <- log_qc_decision(
  process_step = "Temporal harmonization",
  action = "manual_documentation",
  operator = "Kai Zwießler",
  device = "Meteorological Stations SENAMHI: Datasets_QUISOQUEPINA, SIBINACHOCHA_joined.xlsx",
  reason = paste("Removal of duplicate time step: The temporal structure analysis identified duplicate timestamps in individual sheets.",
                 "A comparison of all meteorological measurement columns has shown that no deviations conflicts between the duplicate records.",
                 "The duplicates were therefore classified as redundant records and are removed prior to quality control. removed duplicates n = 1438."
  ))
# duplicate decision station based
qc_logs[[length(qc_logs) + 1]] <- log_qc_decision(
  process_step = "Temporal harmonization",
  action = "manual_documentation",
  operator = "Kai Zwießler",
  device = "Meteorological Station Qori-Kalis, Overlapping Datasets: 8_QORIKALIS_22_06_2025.csv, 9_QORIKALIS_07_07_2025.csv",
  reason = paste("Removal of duplicate time steps: The temporal structure analysis identified duplicate timestamps on sensor basis.",
                 "A comparison of all meteorological measurement columns has shown that no deviations in measurement values of the same time steps are present.",
                 "The duplicates were therefore classified as redundant records and are removed prior to quality control. removed duplicates n = 2836."
  ))

# decision documentation temporal harmonization workflow separation
qc_logs[[length(qc_logs) + 1]] <- log_qc_decision(
  process_step = "Temporal harmonization",
  action = "manual_documentation",
  operator = "Kai Zwießler",
  device = "Data sheet: 10_QORIKALIS_18_08_2025.csv Meteorological station",
  reason = paste("Decision-making original temporal resolution: The temporal structure analysis identified a temporal resolution of 15 minutes for this data file.",
                 "The decision was made to run the whole QC framework on the original temporal resolution before aggregating to a hourly time step.",
                 "This prevents that potential outliers will be concealed after using mathematical operations like arithmetic mean",
                 "in the temporal aggregation workflows. The data will then be re-joined with the master data frame.",
  ))





# Final rename
data_meteo15_harmonized <- data_meteo15_standardized

cat("\n✓ Step 1.02 complete: data_meteo15_harmonized ready (", nrow(data_meteo15_harmonized), "rows)\n")
# ==============================================================================
# END OF Temporal harmonization meteo 15
# ==============================================================================
