#======================================================================
# Script name: 03_01_qc_gross_error_check.R
# Goal(s): 
  # Execution of the gross error check (range test). for the calibrated range and the operation range of the sensor.
  # Provides a report of the results of the gross error check function
  # Flags assignment workflow using apply_qc_flags function
  # Documentation of both of the results using log_qc_decisions function
# Author: Kai Albert Zwießler
# Date: 2026.07.11
# Input Data set:
  # completeness test-flagged master data frame for hydrological data
# Output: 
  # flagged data frame or tibble with one new column:
    # one containing the flag information with the thresholds adjusted to the calibration range of the sensor.
    # no second column has been generated as test results were negative for operation range.
#======================================================================

# ------------------------------------------------------------------------------
# Execution gross error check using Calibration range fabricate threshold information
# ------------------------------------------------------------------------------
hydro_results_gross_error_check_calibration <- qc_gross_error_check(
  df = data_hydro15_completeness_flagged,
  thresholds = HYDRO_QC_CONFIG$GROSS_ERROR_CALIBRATION$THRESHOLDS,
  date_column = HYDRO_MASTER_DF_FRAMEWORK$DATE_COLUMN,
  source_column = HYDRO_MASTER_DF_FRAMEWORK$SOURCE_COLUMN_FILE,
  source_ids = HYDRO_MASTER_DF_FRAMEWORK$SOURCE_IDS15
)
print(hydro_results_gross_error_check_calibration)

# ------------------------------------------------------------------------------
# Execution gross error check using operation range fabricate threshold information
# ------------------------------------------------------------------------------
hydro_results_gross_error_check_operation <- qc_gross_error_check(
  df = data_hydro15_completeness_flagged,
  thresholds = HYDRO_QC_CONFIG$GROSS_ERROR_OPERATION$THRESHOLDS,
  date_column = HYDRO_MASTER_DF_FRAMEWORK$DATE_COLUMN,
  source_column = HYDRO_MASTER_DF_FRAMEWORK$SOURCE_COLUMN_FILE,
  source_ids = HYDRO_MASTER_DF_FRAMEWORK$SOURCE_IDS15
)
print(hydro_results_gross_error_check_operation)

# No detections out of operation range.

# ------------------------------------------------------------------------------
# Application of quality control flag information - CALIBRATION RANGE
# ------------------------------------------------------------------------------
data_hydro15_completeness_flagged <- apply_qc_flags(
  df = data_hydro15_completeness_flagged,
  df_flag_info = hydro_results_gross_error_check$data,
  flag_value = HYDRO_QC_CONFIG$GROSS_ERROR_CALIBRATION$FLAG_VALUE,
  qc_test = "GROSS_ERROR_CALIBRATION",
  merge_col = HYDRO_MASTER_DF_FRAMEWORK$DATE_COLUMN,
  id_col = HYDRO_MASTER_DF_FRAMEWORK$SOURCE_COLUMN_FILE
)


# ------------------------------------------------------------------------------
# Documentation
# ------------------------------------------------------------------------------
qc_logs[[length(qc_logs) + 1]] <- log_qc_decision(
  process_step = "QC Test: Gross Error Check v.1",
  action = "initial_assignment",
  df = hydro_results_gross_error_check$data,
  to_flag = HYDRO_QC_CONFIG$GROSS_ERROR_CHECK$FLAG_VALUE,
  operator = "Kai Zwießler",
  device = HYDRO_MASTER_DF_FRAMEWORK$SOURCE_IDS15,
  qc_threshold = HYDRO_QC_CONFIG$GROSS_ERROR_CALIBRATION$THRESHOLDS,
  reason = paste("For the variable `Absolute Pressure` the Gross Error Check detected for all data, except the piezometers almost a 100% detection rate ",
                 "The documented threshold is set using the calibration range communicated by the fabricant. ",
                 "All Piezometer data passed the test. ",
                 "Outside of the calibration range the measurement uncertainty can be higher than inside the calibration range. ",
                 "The data set will be re-run on the operation range of the sensor (possible measurement range) communicated by the fabricant. ",
                 "This serves as a complementary perspective on how many of the values are at least inside the measurement range of the sensor.",
  tz = TIMEZONE_PROCESS
  ))

qc_logs[[length(qc_logs) + 1]] <- log_qc_decision(
  process_step = "QC Test: Gross Error Check v.2",
  action = "initial_assignment",
  df = hydro_results_gross_error_check$data,
  to_flag = HYDRO_QC_CONFIG$GROSS_ERROR_CHECK$FLAG_VALUE,
  operator = "Kai Zwießler",
  device = HYDRO_MASTER_DF_FRAMEWORK$SOURCE_IDS15,
  qc_threshold = HYDRO_QC_CONFIG$GROSS_ERROR_OPERATION$THRESHOLDS,
  reason = paste("The test have been re-run on the data sets with changed threshold values to the operation range of the sensor./n",
                 "No values are located out of the operation range for neither of the data seets."
  ))

# Final rename
data_hydro15_gross_error_flagged <- data_hydro15_completeness_flagged

cat("\n✓ Step 03.01 complete: data_hydro15_gross_error_flagged ready (", nrow(data_hydro15_gross_error_flagged), "rows)\n")

# ==============================================================================
# END OF GROSS ERROR CHECK HYDRO
# ==============================================================================