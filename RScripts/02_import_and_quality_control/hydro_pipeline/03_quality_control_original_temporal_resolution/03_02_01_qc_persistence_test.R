#======================================================================
# Script name: 03_02_01_qc_persistence_test.R
# Goal(s): 
  # Execution of the persistence test using range metric (part of temporal consistency tests).
  # Provides a report of the results of the persistence test function
  # Flags assignment workflow using apply_qc_flags function
  # Documentation of the results using log_qc_decisions function
# Author: Kai Albert Zwießler
# Input Data set:
# gross error checked-flagged master data frame for hydrological data
# Output: 
  # flagged data frame or tibble with a new column of the test name, containing the flag information and renamed df.
#======================================================================

# ------------------------------------------------------------------------------
# Execution of persistence test for barometer data
# ------------------------------------------------------------------------------
hydro_results_persistence_test <- qc_persistence_test(
  df = data_hydro15_gross_error_flagged,
  metric = HYDRO_QC_CONFIG$PERSISTENCE_TEST15$METRIC,
  thresholds = HYDRO_QC_CONFIG$PERSISTENCE_TEST15$THRESHOLDS_BARO,
  window = HYDRO_QC_CONFIG$PERSISTENCE_TEST15$WINDOW,
  min_coverage = HYDRO_QC_CONFIG$PERSISTENCE_TEST15$MIN_COVERAGE,
  date_column = HYDRO_MASTER_DF_FRAMEWORK$DATE_COLUMN,
  source_column = HYDRO_MASTER_DF_FRAMEWORK$SOURCE_COLUMN_FILE,
  source_ids = HYDRO_QC_CONFIG$PERSISTENCE_TEST15$SOURCE_IDS
)
purrr::walk(hydro_results_persistence_test, print, width = Inf)

# ------------------------------------------------------------------------------
# Application of quality control flag information
# ------------------------------------------------------------------------------
data_hydro15_gross_error_flagged <- apply_qc_flags(
  df = data_hydro15_gross_error_flagged,
  df_flag_info = hydro_results_persistence_test$data,
  flag_value = HYDRO_QC_CONFIG$PERSISTENCE_TEST15$FLAG_VALUE,
  qc_test = "PERSISTENCE_TEST15",
  merge_col = HYDRO_MASTER_DF_FRAMEWORK$DATE_COLUMN,
  id_col = HYDRO_MASTER_DF_FRAMEWORK$SOURCE_COLUMN_FILE
)

# ------------------------------------------------------------------------------
# Documentation
# ------------------------------------------------------------------------------
qc_logs[[length(qc_logs) + 1]] <- log_qc_decision(
  process_step = "QC Test: Persistence Test",
  action = "initial_assignment",
  df = hydro_results_persistence_test$data,
  to_flag = HYDRO_QC_CONFIG$PERSISTENCE_TEST$FLAG_VALUE,
  operator = "Kai Zwießler",
  device = HYDRO_QC_CONFIG$PERSISTENCE_TEST15$SOURCE_IDS,
  reason = paste("Persistence Test results: the data set contains one constant value episode in $data for absolute pressure and temperature alike. ",
                 "Both values are frozen for the same time interval. It was not associated with a protocoled data collection or maintenence event. ",
                 "In the list segement $coverage_problems the data values in absolute presure repeat itself while temperature continues to varry. ",
                 "A loss of connection is protocolled. The data set is approved for further analysis. Total examined values: 3736."
  ))


# Final rename
data_hydro15_persistence_test_flagged <- data_hydro15_gross_error_flagged

cat("\n✓ Step 03.01 complete: data_hydro15_persistence_test_flagged ready (", nrow(data_hydro15_persistence_test_flagged), "rows)\n")
# ==============================================================================
# END OF PERSISTENCE TEST HYDRO
# ==============================================================================