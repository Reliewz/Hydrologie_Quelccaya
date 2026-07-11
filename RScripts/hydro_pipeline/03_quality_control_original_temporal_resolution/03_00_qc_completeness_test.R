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
  # Harmonized master data frame of hydrological data
# Output: 
  # flagged data frame or tibble. A new column is added "completeness_test" containing the flag information.
#======================================================================

# ------------------------------------------------------------------------------
# Execution completeness test
# ------------------------------------------------------------------------------
hydro_results_completeness_test <- qc_completeness_test(
  df = data_hydro15_harmonized,
  measurement_columns = HYDRO_MASTER_DF_FRAMEWORK$MEASUREMENT_COLUMNS,
  date_column = HYDRO_MASTER_DF_FRAMEWORK$DATE_COLUMN,
  source_column = HYDRO_MASTER_DF_FRAMEWORK$SOURCE_COLUMN_FILE,
  source_ids = HYDRO_MASTER_DF_FRAMEWORK$SOURCE_IDS15
)

# ------------------------------------------------------------------------------
# Application of quality control flag information
# ------------------------------------------------------------------------------
data_hydro15_harmonized <- apply_qc_flags(
  df = data_hydro15_harmonized,
  df_flag_info = hydro_results_completeness_test$data,
  flag_value = HYDRO_MASTER_DF_HARMONIZED$FLAG_VALUE,
  qc_test = "completeness_test",
  merge_col = HYDRO_MASTER_DF_FRAMEWORK$DATE_COLUMN,
  id_col = HYDRO_MASTER_DF_FRAMEWORK$SOURCE_COLUMN_FILE
)

# ------------------------------------------------------------------------------
# Documentation
# ------------------------------------------------------------------------------
qc_logs[[length(qc_logs) + 1]] <- log_qc_decision(
  process_step = "QC Test: completeness test",
  action = "initial_assignment",
  df = hydro_results_completeness_test$data,
  to_flag = HYDRO_QC_CONFIG$COMPLETENESS_TEST$FLAG_VALUE,
  operator = "Kai Zwießler",
  device = "All hydrological data sheets with 15 minute temporal resolution",
  reason = paste("Completeness Test results: the individual data sheets contain no missing values and are approved for further analysis.  ",
                 "Total examined values: 284839."
  ))


# Final rename
data_hydro15_completeness_flagged <- data_hydro15_harmonized

cat("\n✓ Step 03.00 complete: data_hydro15_completeness_flagged ready (", nrow(data_hydro15_completeness_flagged), "rows)\n")
# ==============================================================================
# END OF COMPLETENESS TEST HYDRO
# ==============================================================================