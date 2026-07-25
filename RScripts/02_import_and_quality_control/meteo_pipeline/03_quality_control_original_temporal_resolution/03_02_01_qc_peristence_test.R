#======================================================================
# Script name: 03_02_01_qc_peristence_test.R
# Goal(s): 
  # Execution of the persistence test (part of temporal consistency tests).
  # Provides a report of the results of the persistence test function
  # Flags assignment workflow using apply_qc_flags function
  # Documentation of the results using log_qc_decisions function
# Author: Kai Albert Zwießler
# Date: 2026.07.11
# Input Data set:
  # gross error checked-flagged master data frame of meteorological data
# Output: 
  # flagged data frame or tibble with a new column of the test name, containing the flag information.
#======================================================================

# ------------------------------------------------------------------------------
# Execution of persistence test
# ------------------------------------------------------------------------------
meteo_results_persistence_test <- qc_completeness_test(
  df = data_meteo15_gross_error_flagged,
  measurement_columns = METEO_MASTER_DF_FRAMEWORK$MEASUREMENT_COLUMNS,
  date_column = METEO_MASTER_DF_FRAMEWORK$DATE_COLUMN,
  source_column = METEO_MASTER_DF_FRAMEWORK$SOURCE_COLUMN_FILE,
  source_ids = METEO_MASTER_DF_FRAMEWORK$SOURCE_IDS15
)

# ------------------------------------------------------------------------------
# Application of quality control flag information
# ------------------------------------------------------------------------------
data_meteo15_gross_error_flagged <- apply_qc_flags(
  df = data_meteo15_gross_error_flagged,
  df_flag_info = meteo_results_persistence_test$data,
  flag_value = METEO_QC_CONFIG$PERSISTENCE_TEST$FLAG_VALUE,
  qc_test = "PERSISTENCE_TEST",
  merge_col = METEO_MASTER_DF_FRAMEWORK$DATE_COLUMN,
  id_col = METEO_MASTER_DF_FRAMEWORK$SOURCE_COLUMN_FILE
)

# ------------------------------------------------------------------------------
# Documentation
# ------------------------------------------------------------------------------
qc_logs[[length(qc_logs) + 1]] <- log_qc_decision(
  process_step = "QC Test: Persistence Test",
  action = "initial_assignment",
  df = meteo_results_persistence_test$data,
  to_flag = METEO_QC_CONFIG$PERSISTENCE_TEST$FLAG_VALUE,
  operator = "Kai Zwießler",
  device = "Datasheet: 10_QORIKALIS_18_08_2025.csv",
  reason = paste("Gross Error Test results: the data set contains one missing value for the precipitation variable. ",
                 "All other meteorological variables reached 100% completeness for the respective time frame while precipitation reached 99.97% completeness. ",
                 "The data set is approved for further analysis. Total examined values: 3736."
  ))


# Final rename
data_meteo15_persistence_test_flagged <- data_meteo15_gross_error_flagged

cat("\n✓ Step 03.01 complete: data_meteo15_persistence_test_flagged ready (", nrow(data_meteo15_persistence_test_flagged), "rows)\n")
# ==============================================================================
# END OF PERSISTENCE TEST METEO
# ==============================================================================