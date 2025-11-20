#======================================================================
# Scriptname: quality_control_waterlevel_lagoon.R
# Goal(s): 
  # Documentation steps in Power Quiery
# Author: Kai Albert Zwießler
# Date: 2025.11.12
# Input Dataset: data/WLS_merged.xlsx
# Outputs: 
  # 
# Units:
  # Abs.pres <- kPa
  # Temp <- °C
# Sensor information:
  # Datalogger lagoon S/N: 21826493
  # Sensor lagoon WLS_L S/N: 21826493
  # Datalogger Outlet S/N: 21826515
  # Sensor Outlet WLS_O S/N: 21826515

#======================================================================
##Documentation of Power Quiery steps##
# First column removed
# Correct column assigned as headlines
# Changed column names from "Count" to "RECORD"
# Adding customized column to convert the date from US to format: YYYY-MM-DD hh:mm:ss
    # = DateTime.FromText([#"Date Time, GMT-5:00"], "en-US")
    # = DateTime.ToText([Date_Standardized], "yyyy-MM-dd HH:mm:ss")
# Changing order of column & removing old Date column
# Changing type to decimal with location information "English (USA)"
# Data in Folder merged
# Name change of columns
# Assigning a Source.Name to every line
#======================================================================

library(dplyr)
library(lubridate)
library(readxl)
library(renv)

#Sources required
source("RScripts/01_import/load_and_standardize.R")
source("RScripts/utils/qc_functions/function_time.R")

# ========== CONFIGURATION ==========
# Parameters
sheet_name <- "Rinput"
date_column <- "Date"        # Column name for Date
id_column <- "ID"         # Column for identification
output_column <- "time_diff" # Column for calculated output
# ===================================

cat("Step 1: Columns and data type")
# Assigning multiple columns from logi -> chr format
data_raw <- data_raw %>%
  mutate(across(c(Connection_off, Connection_on, Host_connected, Data_end), 
                as.character))
cat("✓ Converted connection status columns to character format")
message("columns have been assigned the correct type.")

cat("Step 2: No missing values in Date column found. Continuing with Analysis")

# calculating the time different between the timesteps for temporal consistency test. creating time_diff column, using function_time.R
interval_check <- calc_time_diff(
  df = data_raw,
  id_col = id_column,
  date_col = date_column,
  out_col = output_column
)


# ========== 3b Analyze intervals per WLS group ==========
cat("\nStep3b: Analyzing time intervals per WLS...\n")

interval_summary <- interval_check %>%
  filter(!is.na(time_diff)) %>%  # Filter/Remove NA values (first entry per WLS)
  group_by(ID) %>%
  summarise(
    n_measurements = n(),
    min_interval = min(time_diff),
    max_interval = max(time_diff),
    average_interval = mean(time_diff),
    n_15min = sum(time_diff == 15), # Count specific intervals:
    n_60min = sum(time_diff == 60),
    n_between = sum(time_diff > 15 & time_diff < 60),
    n_above_60 = sum(time_diff > 60),   # gaps!
    n_below_15 = sum(time_diff < 15),  # Unexpected values potentially in connection with maintanance and sensor errors
    .groups = "drop" # same effect than the command ungroup(), special for summarize.
  )

# Display results
cat("\n=== Interval Summary by Water Level Sensors ===\n")
print(interval_summary, n = Inf)
