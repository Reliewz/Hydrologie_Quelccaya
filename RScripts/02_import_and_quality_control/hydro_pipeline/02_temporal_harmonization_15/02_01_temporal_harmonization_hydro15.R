#======================================================================
# Script name: 01_02_temporal_harmonization_hydro15.R
# Goal(s): 
  # Elimination of maintenance-related fractional time steps
 
 # Elimination of duplicate records, based on decision making in temporal structure analysis and documentation of the decision making.
  # Temporal gap filling in between records for 15 minute temporal resolution data based on the analysis of 01_1_temporal structure analysis
  # Documentation for each working step
# Author: Kai Albert Zwießler
# Date: 2026.06.15
# Input Data set:
  # Standardized master data frame hydrological data from the load_and_standardize_hydro workflow

# Output: 
  # data_hydro15_harmonized
# =======================================

# ------------------------------------------------------------------------------
# Preparation of sensor maintenance information
# ------------------------------------------------------------------------------
data_sensor_maintenance_events <- data_hydro_standardized |> 
  filter(
    if_any( # required to check all columns (comes from across family)
      all_of(HYDRO_MASTER_DF_FRAMEWORK$INFO_COLUMNS), ~ !is.na(.) & . != "")) |> # filter all not NA and not empty
  select(Date, Source.Code, ID, all_of(HYDRO_MASTER_DF_FRAMEWORK$INFO_COLUMNS)) # select columns relevant to display when the columns were disconnected

# ------------------------------------------------------------------------------
# Elimination of maintenance caused fractional time steps
# ------------------------------------------------------------------------------
data_hydro_standardized <- data_hydro_standardized %>%
  filter(!if_all(all_of(HYDRO_MASTER_DF_FRAMEWORK$MEASUREMENT_COLUMNS), is.na
    ))

# ------------------------------------------------------------------------------
# Duplicates
# ------------------------------------------------------------------------------

# No duplicates present neither for individual files nor for the sensor concatenation

# ------------------------------------------------------------------------------
# Time series completion Gap-Filling of missing 15 minute time steps
# ------------------------------------------------------------------------------

data_hydro_standardized <- complete_timeseries(
  df = data_hydro_standardized,
  date_column = HYDRO_MASTER_DF_FRAMEWORK$DATE_COLUMN,
  source_column = HYDRO_MASTER_DF_FRAMEWORK$SOURCE_COLUMN_FILE,
  source_ids = HYDRO_MASTER_DF_FRAMEWORK$SOURCE_IDS15,
  time_step = HYDRO_MASTER_DF_STANDARDIZED$TIME_STEP15
)
# no missing time steps detected for the 15-minute files.

# ------------------------------------------------------------------------------
# Documentation
# ------------------------------------------------------------------------------
# Decision removal maintenance event fractional time steps
qc_logs[[length(qc_logs) + 1]] <- log_qc_decision(
  process_step = "Temporal harmonization",
  action = "manual_documentation",
  operator = "Kai Zwießler",
  device = "All hydrological sensors",
  reason = paste("Removal of fractional time steps: During the temporal structure analysis fractional time steps for all hydrological sensors were identified. ",
                 "the reason was a protocolled re-booting mechanism, which occured after maintenance or data collection events. ",
                 "For further analysis this rows are excluded, as they do not provide additional information content. ", 
                 "total amount of removed fractional time steps for the investigation time period n = 298."
  ))


# Final rename
data_hydro15_harmonized <- data_hydro_standardized

cat("\n✓ Step 2.01 complete: data_hydro15_harmonized ready (", nrow(data_hydro15_harmonized), "rows)\n")
# ==============================================================================
# END OF Temporal Harmonization hydro
# ==============================================================================