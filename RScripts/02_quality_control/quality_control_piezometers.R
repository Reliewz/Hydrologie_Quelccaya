#======================================================================
# Scriptname: load_and_standardize.R
# Goal(s): 
# Documentation of steps taken in Power Quiery
# Change Date format to POSIXct
# Preperation of Analysis of temporal consistency -> Note that the "time_diff" column will be established for each data set but             analyszed is the respective QC_ scripts.
# Author: Kai Albert Zwießler
# Date: 2025.11.14
# Input Dataset: Hydrological_data/piezometer_data/PZ_merged/PZ_merged/All_PZ_merged.xlsx
# Outputs: 
# figures/temperature_timeseries.png	#
# Units:
# Abs.pres <- kPa
# Temp <- °C
# Sensor information:
# PZ01  S/N: 21826509
# PZ02  S/N: 21826502
# PZ03  S/N: 21826497
# PZ04  S/N: 21826519
# PZ05  S/N: 21826512
# PZ06  S/N: 21826504
# PZ07  S/N: 21826505
# PZ08  S/N: 21826596
# PZ09  S/N: 21826594
# PZ010 S/N: 21826516
# PZ011 S/N: 21826500
# PZ12  S/N: 21826503

#======================================================================
##Documentation of Power Quiery steps##
# All Piezometer data has been loaded from one folder.
# First column removed from every data set with example file
# Correct columns assigned as headlines
# Changed column names to universal terms across all data sets
# Adding customized column to convert the date from US to format: YYYY-MM-DD hh:mm:ss
# = DateTime.FromText([#"Date Time, GMT-5:00"], "en-US")
# = DateTime.ToText([Date_Standardized], "yyyy-MM-dd HH:mm:ss")
# Changing order of column & removing old Date column
# Changing type to decimal with location information "English (USA)"
# Assigning a Source.Name to every line
# Extracting Piezometer_ID and WLS_ID from source.name
# All Piezometers are merged in Excel to further analyse them in RStudio
#======================================================================

#Sources required
source("RScripts/01_import/load_and_standardize.R")
source("RScripts/utils/qc_functions/function_time.R")
source("RScripts/utils/qc_functions/function_coordinate_transformation.R")

# ========== CONFIGURATION ==========
# Parameters
sheet_name <- "Rinput"
date_column <- "Date"        # Column name for Date
id_column <- "ID"         # Column for identification
output_column <- "time_diff" # Column for calculated output
# Coordinate data: Piezometer + BAROM
utm_coords_pz <- data.frame(Device = c(paste0("PZ", sprintf("%02d", 1:12)), "BAROM"),
                            x = c(299184.3993, 299279.3782, 299475.9968, 299601.0980, 299607.1613, 
                                  299479.9303, 299432.1672, 299302.1533, 299168.8984, 299240.7638, 
                                  299053.4642, 299322.6926, 298822.5337),
                            y = c(8463245.9423, 8463168.2165, 8463142.1306, 8463205.7897, 8463323.1859, 
                                  8463313.4492, 8463202.6988, 8463294.1563, 8463376.2507, 8463452.2814, 
                                  8463383.1424, 8463376.6515, 8463357.8907))
# ===================================

cat("Step 1: Columns and data type")
# Assigning multiple columns from logi -> chr format
data_raw <- data_raw %>%
  mutate(across(c(Connection_off, Connection_on, Host_connected, Data_end), 
                as.character))
cat("✓ Converted connection status columns to character format")
message("columns have been assigned the correct type.")

cat("Step 2: No missing values found in Date column. Continueing with Analysis...")

cat("Step 3: Coordinate transformation. UTM 19S to WGS84")
wgs_coords_pz <- utm_to_latlon(
  df = utm_coords_pz,
  x_col = "x",
  y_col = "y",
  zone = 19,
  hemisphere = "south"
)



# calculating the time different between the timesteps for temporal consistency test. creating time_diff column, using function_time.R
interval_check <- calc_time_diff(
  df = data_raw,
  id_col = id_column,
  date_col = date_column,
  out_col = output_column
)


# ========== 4b Analyze intervals per piezometer group ==========
cat("\nStep4b: Analyzing time intervals per piezometer...\n")

interval_summary <- interval_check %>%
  filter(!is.na(time_diff)) %>%  # Filter/Remove NA values (first entry per piezometer)
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
cat("\n=== Interval Summary by Piezometer ===\n")
print(interval_summary, n = Inf)


