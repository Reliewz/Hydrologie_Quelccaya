#=================================================================================================================
# Scriptname: 00_config_hydro.R
# Goal(s): 
  # Provides hydrological scripts and workflows with its specific configuration
# Author: Kai Albert Zwießler
# Date: 2025.12.24
#=================================================================================================================

# ====== LOAD & STANDARDIZE WORKFLOWs CONFIGURATION ======
# ==========  ==========
#Dataframe
input_file <- "D:/RProjekte/Hydrologie_Quelccaya/Datenquellen/Hydrological_data/piezometer_data/PZ_merged/PZ_merged/All_PZ_merged.xlsx"
#alternative paths: 
# WLS: D:/RProjekte/Hydrologie_Quelccaya/Datenquellen/Hydrological_data/waterlevel_data/WLS_merged.xlsx
#Parameters
sheet_name <- "Rinput"
# ===================================

# ====== QUALITY-CONTROL WORKFLOWs CONFIGURATION ======
# Global parameters
sensor_units <- list(Abs_pres = "kPa", Temp = "°C")
sensor_information_pz <- list(
  PZ01_SN = "21826509",
  PZ02_SN = "21826502",
  PZ03_SN = "21826497",
  PZ04_SN = "21826519",
  PZ05_SN = "21826512",
  PZ06_SN = "21826504",
  PZ07_SN = "21826505",
  PZ08_SN = "21826596",
  PZ09_SN = "21826594",
  PZ10_SN = "21826516",
  PZ11_SN = "21826500",
  PZ12_SN = "21826503")

# WLS
sensor_information_wls <- list(
  WLS_L_SN = "21826493",
  WLS_O_SN = "21826515")

# = TEMPORAL CONSISTENCY =

# Process Parameters temporal consistency
date_column <- "Date"        # Column name for timestamp
id_column <- "ID"         # Column for identification (e.g. PZ01_01m PZ01_02, PZ02_01 (...))
sensor_group_column <- "sensor_group" # One level above id_column for identification (e.g. PZ01, PZ02 (...))
output_column <- "time_diff" # Column for calculated output
timediff_column <- "time_diff" # Column for further analysis in the field of temporal consistency
measurement_columns <- c("Abs_pres", "Temp")
maintenance_info_columns <- c("Connection_off", "Connection_on", "Host_connected", "Data_end")
# apply qc flags workflow
QC_LEVELS <- c(
  "temporal_consistency",
  "physical_plausibility"
)
merge_column <- "RECORD"
# Workflow Parameters:
record_tolerance <- 1
timezone_data <- "America/Lima"
timezone_process <- "Europe/Berlin"
# Outputs
log_file_tc <- "results/logs/qc_log_piezo_temporal_consistency.csv"
log_file_duplicates <- "results/logs/qc_log_piezo_duplicates.csv"
# = DUPLICATES

# = PHYSICAL PLAUSIBILITY




