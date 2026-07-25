#======================================================================
# Script name: 03_01_qc_gross_error_check.R
# Goal(s): 
  # Execution of the gross error check (range test).
  # Provides a report of the results of the gross error check function
  # Flags assignment workflow using apply_qc_flags function
  # Documentation of the results using log_qc_decisions function
# Author: Kai Albert Zwießler
# Date: 2026.07.11
# Input Data set:
  # completeness test-flagged master data frame of meteorological data
# Output: 
  # flagged data frame or tibble with a new column of the test name, containing the flag information.
#======================================================================

# ------------------------------------------------------------------------------
# Execution gross error check
# ------------------------------------------------------------------------------
meteo_results_gross_error_check <- qc_gross_error_check(
  df = data_meteo15_completeness_flagged,
  thresholds = METEO_QC_CONFIG$GROSS_ERROR_CHECK$THRESHOLDS,
  date_column = METEO_MASTER_DF_FRAMEWORK$DATE_COLUMN,
  source_column = METEO_MASTER_DF_FRAMEWORK$SOURCE_COLUMN_FILE,
  source_ids = METEO_MASTER_DF_FRAMEWORK$SOURCE_IDS15
)
print(meteo_results_gross_error_check)

# ------------------------------------------------------------------------------
# Application of quality control flag information
# ------------------------------------------------------------------------------
data_meteo15_completeness_flagged <- apply_qc_flags(
  df = data_meteo15_completeness_flagged,
  df_flag_info = meteo_results_gross_error_check$data,
  flag_value = METEO_QC_CONFIG$GROSS_ERROR_CHECK$FLAG_VALUE,
  qc_test = "GROSS_ERROR_CHECK",
  merge_col = METEO_MASTER_DF_FRAMEWORK$DATE_COLUMN,
  id_col = METEO_MASTER_DF_FRAMEWORK$SOURCE_COLUMN_FILE
)

# ------------------------------------------------------------------------------
# Documentation
# ------------------------------------------------------------------------------
qc_logs[[length(qc_logs) + 1]] <- log_qc_decision(
  process_step = "QC Test: Gross Error Check",
  action = "initial_assignment",
  df = meteo_results_gross_error_check$data,
  to_flag = METEO_QC_CONFIG$GROSS_ERROR_CHECK$FLAG_VALUE,
  operator = "Kai Zwießler",
  device = "Datasheet: 10_QORIKALIS_18_08_2025.csv",
  qc_threshold = METEO_QC_CONFIG$GROSS_ERROR_CHECK$THRESHOLDS,
  reason = paste("Gross Error Check results: 24 values have been detected using the thresholds of the sensors operation range communicated by the fabricant. ",
                 "The detections arise from the variable `Wind Direction (WD)`. ",
                 "Since all days have exact the same value 255.2 the probability is very low, that they represent real meteorological signals. ",
                 "And rather stem from a sensor mal functioning ",
                 "The data is validated for next qc steps."
  ))


# Final rename
data_meteo15_gross_error_flagged <- data_meteo15_completeness_flagged

cat("\n✓ Step 03.01 complete: data_meteo15_gross_error_flagged ready (", nrow(data_meteo15_gross_error_flagged), "rows)\n")
# ==============================================================================
# END OF GROSS ERROR CHECK METEO
# ==============================================================================