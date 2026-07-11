#======================================================================
# Script name: 03_00_qc_completeness_test.R
# Goal(s): 
  # Execution of the completeness test for original time steps
  # Provides a report of the results of the qc_completeness_test function
  # Flags assignment workflow using apply_qc_flags function
  # Documentation of the results using log_qc_decisions function
# Author: Kai Albert Zwießler
# Date: 2026.07.10
# Input Data set:
# Harmonized master data frame of meteorological data
# Output: 
  # flagged data frame or tibble. A new column is added "completeness_test" containing the flag information.
#======================================================================

# ------------------------------------------------------------------------------
# Execution completeness test
# ------------------------------------------------------------------------------
meteo_results_completeness_test <- qc_completeness_test(
  df = data_meteo15_harmonized,
  measurement_columns = METEO_MASTER_DF_FRAMEWORK$MEASUREMENT_COLUMNS,
  date_column = METEO_MASTER_DF_FRAMEWORK$DATE_COLUMN,
  source_column = METEO_MASTER_DF_FRAMEWORK$SOURCE_COLUMN_FILE,
  source_ids = METEO_MASTER_DF_FRAMEWORK$SOURCE_IDS15
)
print(meteo_results_completeness_test$detection_summary)
print(meteo_results_completeness_test$data)

# ------------------------------------------------------------------------------
# Application of quality control flag information
# ------------------------------------------------------------------------------
data_meteo15_harmonized <- apply_qc_flags(
  df = data_meteo15_harmonized,
  df_flag_info = meteo_results_completeness_test$data,
  flag_value = METEO_QC_CONFIG$COMPLETENESS_TEST$FLAG_VALUE,
  qc_test = "COMPLETENESS_TEST",
  merge_col = METEO_MASTER_DF_FRAMEWORK$DATE_COLUMN,
  id_col = METEO_MASTER_DF_FRAMEWORK$SOURCE_COLUMN_FILE
)

# ------------------------------------------------------------------------------
# Documentation
# ------------------------------------------------------------------------------
qc_logs[[length(qc_logs) + 1]] <- log_qc_decision(
  process_step = "QC Test: completeness test",
  action = "initial_assignment",
  df = meteo_results_completeness_test$data,
  to_flag = METEO_QC_CONFIG$COMPLETENESS_TEST$FLAG_VALUE,
  operator = "Kai Zwießler",
  device = "Datasheet: 10_QORIKALIS_18_08_2025.csv",
  reason = paste("Completeness Test results: the data set contains one missing value for the precipitation variable. ",
                 "All other meteorological variables reached 100% completeness for the respective time frame while precipitation reached 99.97% completeness. ",
                 "The data set is approved for further analysis. Total examined values: 3736."
  ))


# Final rename
data_meteo15_completeness_flagged <- data_meteo15_harmonized

cat("\n✓ Step 03.00 complete: data_meteo15_completeness_flagged ready (", nrow(data_meteo15_completeness_flagged), "rows)\n")
# ==============================================================================
# END OF COMPLETENESS TEST METEO
# ==============================================================================