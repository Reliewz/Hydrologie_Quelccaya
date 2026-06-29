#======================================================================
# Script name: 01_03_temporal_harmonization_meteo.R
# Goal(s): 
  # Elimination of duplicate records, based on decision making in temporal structure analysis and documentation of the decision making.
  # Aggregation of time stamps to 60 min intervals
  # temporal gap filling in between records based on the analysis of 01_1_temporal structure analysis
  # Documentation for each working step
# Author: Kai Albert Zwießler
# Date: 2026.06.15
# Input Data set:
  # Standardized meteorological data from the load_and_standardize_meteo workflow 
# Output: 
  # Meteorological united data frame, named data_meteo_harmonized
# =======================================

# ------------------------------------------------------------------------------
# Elimination of date - duplicates and Documentation
# ------------------------------------------------------------------------------
# Duplicate elimination based on the previous temporal structure analysis.
data_meteo <- data_meteo %>%
  distinct(Source.Code, Date, .keep_all = TRUE) # Check for duplicates in the two provided columns and keep all other records with .keep_all = TRUE


# ------------------------------------------------------------------------------
# 15-min-Data -> 60 min data aggregation for data sheet 10_QORIKALIS_18_08_2025.csv
# ------------------------------------------------------------------------------
# temporal aggregation 15 -> 60 minutes
results <- aggregate_15min_to_hourly(
  df            = data_meteo,
  agg_config    = METEO_MASTER_DF$METEO_AGGREGATION_FUNCTIONS,
  date_column   = METEO_MASTER_DF$DATE_COLUMN,
  source_column = METEO_MASTER_DF$SOURCE_COLUMN,
  source_id     = METEO_MASTER_DF$SOURCE_ID,
  min_coverage  = METEO_MASTER_DF$MIN_COVERAGE
)

data_meteo_2 <- results$data




# ------------------------------------------------------------------------------
# Gap-Filling of missing hourly values. Harmonization to 60 minute timesteps for all data sets
# ------------------------------------------------------------------------------
tidyr::complete()

# ------------------------------------------------------------------------------
# Documentation
# ------------------------------------------------------------------------------
# duplicate decision
qc_logs[[length(qc_logs) + 1]] <- log_qc_decision(
  process_step = "Temporal harmonization",
  action = "manual_documentation",
  operator = "Kai Zwießler",
  device = "Meteorological Stations SENAMHI: Datasets_QUISOQUEPINA, SIBINACHOCHA_joined.xlsx",
  reason = paste("The temporal structure analysis identified duplicate timestamps.",
                 "A comparison of all meteorological measurement columns has shown that no deviations conflicts between the duplicate records.",
                 "The duplicates were therefore classified as redundant records and are removed prior to quality control. removed duplicates = 1438."
  ))

# decision documentation temporal aggregation
qc_logs[[length(qc_logs) + 1]] <- log_qc_decision(
  process_step = "Temporal aggregation",
  action = "manual_documentation",
  operator = "Kai Zwießler",
  device = "Meteorological station Qori-Kalis data: 10_QORIKALIS_18_08_2025.csv",
  reason = paste("The temporal structure analysis identified a temporal resolution of 15 minutes for this data file.",
                 "The temporal resolution has been aggregated from 15 to 60 minutes hourly time steps.",
                 "The variable wind direction has been aggregated using vector_mean_wd function instead of the arithmetic mean.",
                 "The variable wind direction has been aggregated using vector_mean_wd function instead of the arithmetic mean."
  ))

# Final rename
data_meteo_harmonized <- data_meteo_standardized

cat("\n✓ Step 1 complete: data_meteo_harmonized ready (", nrow(data_meteo_harmonized), "rows)\n")
# ==============================================================================
# END OF 01_03_temporal_harmonization_meteo
# ==============================================================================
