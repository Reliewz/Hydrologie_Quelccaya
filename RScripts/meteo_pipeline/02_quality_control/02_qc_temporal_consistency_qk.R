#====================================================================
# Skript name: 02_qc_temporal_consistency_qk.R
# Goals:
    # assigning correct format for Date column
    # identifying missing values and safing them for further analysis in qc_analysis script
    # Aggregating 15 Minute time-step to hourly time-step data
# Author: Kai Albert Zwießler
# Date: 2025.11.06
# Input Dataset: processed/QoriKalis_merged.xlsx
# Outputs: 
#===================================================================

renv::snapshot()
renv::status
#Sources required
source("RScripts/01_import/load_and_standardize.R")
source("RScripts/utils/qc_functions/function_time.R")
source("RScripts/utils/qc_functions/function_timediff_sum.R")
source("RScripts/utils/qc_functions/function_interval_determination.R")



# ========== CONFIGURATION ==========
#Parameters
#Process Parameters
date_column <- "Date"        # Column name for timestamp
id_column <- "ID"         # Column for identification
output_column <- "time_diff" # Column for calculated output
timediff_column <- "time_diff" # Column for further analysis in the field of temporal consistency 
measurement_columns <- c("AirTC", "RH", "Precip_Tot", "WS", "WS_Max", "WD", "DewP")

# Metadata parameters
sensor_units <- list(AirTC = "°C", RH = "%", Precip_Tot = "mm", WS = "m/s", WS_Max = "m/s", WD = "°", Dewp = "°C")
Sensor_information <- list(
  AirTC_RH_S-THC-M008_SN = "21666169",
  Rain_Gauge_HOBO_S-RGB-M002_SN = "21673752",
  Wind_HOBO_S-WCF-M003_SN = "21742435")

#Workflow Parameter
timezone <- "America/Lima GMT +5"

# ======STEP 1  Starting with the temporal evaluation if time steps are uniform and tiding steps are necessary. =======
cat("Starting with the temporal evaluation if timesteps are uniform and tiding steps are necessary.")

# calculating the time different between the time steps for temporal consistency test. creating time_diff column, using function_time.R
interval_check <- calc_time_diff(
  df = data_raw,
  id_col = id_column,
  date_col = date_column,
  out_col = output_column
)


# ========== 1a Analyze intervals and generate statistical summary with function_timediff_sum.R ==========
cat("\nStep4a: Analyzing time temporal consistency intervals per piezometer...\n")
interval_summary <- sum_timediff(
  df = interval_check,
  id_col = id_column,
  date_col = date_column,
  td_col = output_column
)
cat("\n=== Interval Summary by Piezometer group ===\n")
print(interval_summary, n = Inf)

# ========== STEP 1b: Identify columns that have no information content ==========
cat("\n=== STEP 4b: Prepairing to remove columns without any information content (NA) ===\n")

# Identify rows with NA in one of measurement columns and safe it for further examination in the dataframe rows_with_na
rows_with_na <- data_raw %>%
  mutate(
    row_id = row_number(), # extracts the original row number from the dataset. Because filter() function would assign new ones.
    has_any_na = is.na(AirTC) | is.na(RH) | is.na(Precip_Tot) | is.na(WS) | is.na(WS_Max) | is.na(WD) | is.na(DewP) # if one of the measured values columns contains NA it gets stored in the object has_any_na.
  ) %>%
  filter(has_any_na == TRUE) # Since the output of is.na() function is logical (TRUE/FALSE) == makes sure that only outputs with TRUE get filtered.

# Summary
cat("Total rows with NA:", nrow(rows_with_na), "\n")
cat("  - AirTC NA:", sum(is.na(rows_with_na$AirTC)), "\n")
cat("  - RH NA:    ", sum(is.na(rows_with_na$RH)), "\n")
cat("  - Precip_Tot NA:    ", sum(is.na(rows_with_na$Precip_Tot)), "\n")
cat("  - WS NA:    ", sum(is.na(rows_with_na$WS)), "\n")
cat("  - WS_Max NA:    ", sum(is.na(rows_with_na$WS_Max)), "\n")
cat("  - WD NA    ", sum(is.na(rows_with_na$WD)), "\n")
cat("  - DewP NA:    ", sum(is.na(rows_with_na$DewP)), "\n")
message("Do NA values exist in one of the measurement columns?")


