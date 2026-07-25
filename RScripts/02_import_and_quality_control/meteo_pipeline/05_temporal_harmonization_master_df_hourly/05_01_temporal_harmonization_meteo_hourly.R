#======================================================================
# Script name: 05_01_temporal_harmonization_meteo_hourly.R
# Goal(s): 
  # Aggregation of time steps from 15 to 60 min intervals of quality controlled 10_QORIKALIS_18_08_2025.csv
  # rejoin of aggregated 10_QORIKALIS_18_08_2025.csv with master data frame meteo
  # Temporal gap filling for master data frame based on the analysis of 04_01_temporal structure analysis
  # Documentation for each working step
# Author: Kai Albert Zwießler
# Date: 2026.06.15
# Input Data set:
  # Standardized meteorological data from the load_and_standardize_meteo workflow + quality controlled 10_QORIKALIS_18_08_2025.csv 15 min resolution data sheet
# Output: 
  # Meteorological master data frame, named data_meteo_harmonized
#======================================================================

# ------------------------------------------------------------------------------
# 15-min-Data -> 60 min data aggregation for data sheet 10_QORIKALIS_18_08_2025.csv
# ------------------------------------------------------------------------------
# temporal aggregation 15 -> 60 minutes
results <- aggregate_15min_to_hourly(
  df            = data_meteo_standardized,
  agg_config    = METEO_MASTER_DF$METEO_AGGREGATION_FUNCTIONS,
  date_column   = METEO_MASTER_DF$DATE_COLUMN,
  source_column = METEO_MASTER_DF$SOURCE_COLUMN,
  source_id     = METEO_MASTER_DF$SOURCE_ID,
  min_coverage  = METEO_MASTER_DF$MIN_COVERAGE
)

data_meteo_standardized <- results$data

# rejoin with master data frame meteo
bind_rows()

# ------------------------------------------------------------------------------
# Gap-Filling of missing hourly values of master df meteo
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Documentation
# ------------------------------------------------------------------------------
# Decision temporal aggregation 15 -> 60
qc_logs[[length(qc_logs) + 1]] <- log_qc_decision(
  process_step = "Temporal harmonization",
  action = "manual_documentation",
  operator = "Kai Zwießler",
  device = "Data file: 10_QORIKALIS_18_08_2025.csv",
  reason = paste("Aggregation to hourly temporal intervals: The temporal structure analysis identified a temporal resolution of 15 minutes for this data file.",
                 "The temporal resolution has been aggregated from 15 to 60 minutes hourly time steps.",
                 "The variable wind direction has been aggregated using vector_mean_wd function instead of the arithmetic mean.",
                 "Correct amount of aggregated rows. Before 3736 after 935 with the first and last hour of the data set containing 2 measurements instead of the",
                 "expected 4. "
  ))
