#=================================================================================================================
# Scriptname: 00_config_hydro.R
# Goal(s): 
  # Provides hydrological scripts and workflows with its specific configuration
# Author: Kai Albert Zwießler
# Date: 2025.12.24
#=================================================================================================================
# ==============================================================================
# HYDRO QC PIPELINE - CONFIGURATION
# ==============================================================================

#------------------------------------------------------------------------------
# FILE PATHS
# -----------------------------------------------------------------------------

  # Input data
  INPUT_PIEZOMETER <- "D:/RProjekte/Hydrologie_Quelccaya/Datenquellen/Hydrological_data/piezometer_data/PZ_merged/PZ_merged/All_PZ_merged.xlsx"
  INPUT_WATERLEVEL <- "D:/RProjekte/Hydrologie_Quelccaya/Datenquellen/Hydrological_data/waterlevel_data/WLS_merged.xlsx"
  
  # Output directories
  DIR_LOGS <- "results/hydro_pipeline/logs"
  DIR_CHECKPOINTS <- "results/hydro_pipeline/pipeline_debugging"
  DIR_PLOTS <- "results/hydro_pipeline/plots"
  DIR_TEMPORAL_RESULTS <- "results/temporal"
  DIR_TABLES <- "results/hydro_pipeline/tables"

# ====== LOAD & STANDARDIZE WORKFLOWs CONFIGURATION ======
# ------------------------------------------------------------------------------
# IMPORT SETTINGS
# ------------------------------------------------------------------------------ 

  SHEET_NAME <- "Rinput"
  TIMEZONE_DATA <- "America/Lima"
  TIMEZONE_PROCESS <- "Europe/Berlin"
# ===================================

# ====== QUALITY-CONTROL WORK FLOWs CONFIGURATION ======
# Global parameters
SENSOR_UNITS <- list(Abs_pres = "kPa", Temp = "°C")
SENSOR_SN_PIEZOMETER <- list(
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
SENSOR_SN_WLS <- list(
  WLS_L_SN = "21826493",
  WLS_O_SN = "21826515")

# ------------------------------------------------------------------------------
# QC PARAMETERS
# ------------------------------------------------------------------------------

# Temporal Consistency
MIN_INTERVAL_MINUTES <- 15
MAX_GAP_HOURS <- 24
date_column <- "Date"        # Column name for time stamp
id_column <- "ID"         # Column for identification (e.g. PZ01_01m PZ01_02, PZ02_01 (...))
sensor_group_column <- "sensor_group" # One level above id_column for identification (e.g. PZ01, PZ02 (...))
output_column <- "time_diff" # Column for calculated output
timediff_column <- "time_diff" # Column for further analysis in the field of temporal consistency
measurement_columns <- c("Abs_pres", "Temp")
maintenance_info_columns <- c("Connection_off", "Connection_on", "Host_connected", "Data_end")
TC_FLAGS_COLUMN <- "temporal_consistency"
RECORD_TOLERANCE <- 1

# Physical Plausibility
ABS_PRES_MIN <- 0
ABS_PRES_MAX <- 200  # kPa
TEMP_MIN <- -10
TEMP_MAX <- 40       # °C
PP_FLAGS_COLUMN <- "physical plausibility"

# Duplicates
RECORD_TOLERANCE <- 1
DUPLICATE_CHECK_COLS <- c("Date", "ID")

# apply qc flags workflow
ALLOWED_QC_LEVELS <- c(
  "temporal_consistency",
  "physical_plausibility"
)
merge_column <- "RECORD"


# ------------------------------------------------------------------------------
# LOG FILE PATHS 
# ------------------------------------------------------------------------------

LOG_TEMPORAL <- file.path(DIR_LOGS, "qc_log_temporal_consistency.csv")
LOG_PHYSICAL <- file.path(DIR_LOGS, "qc_log_physical_plausibility.csv")
LOG_DUPLICATES <- file.path(DIR_LOGS, "qc_log_duplicates.csv")
LOG_SUMMARY <- file.path(DIR_LOGS, "qc_summary_report.csv")



