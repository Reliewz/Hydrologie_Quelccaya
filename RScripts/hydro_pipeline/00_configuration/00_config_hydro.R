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


#------------------------------------------------------------------------------
# Import Section
# -----------------------------------------------------------------------------

# Column names
COLUMN_RENAME_MAP <- c(
  "Anz."               = "Record",
  "Abs.Druck..kPa"     = "Abs_pres",
  "Temp....C"          = "Temp",
  "Koppler.abgetrennt" = "Connection_off",
  "Koppler.verbunden"  = "Connection_on",
  "Host.verbunden"     = "Host_connected",
  "Dateiende"          = "Data_end"
)


# ID column assignment
ID_PIEZOMETER <- "ID"

# Folder Import data

#WLS outlet
FOLDER_IMPORT_PATH_WLS_O <- "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\waterlevel_outlet\\outlet_input_data"
FILE_SELECTION_WLS_O <- c("21826515_QK_salida_25_02_2025.csv", "21826515_QK_salida_19_11_25.csv", "21826515_QK_salida_24_03_26.csv")

# ========== PIEZOMETER IMPORT CONFIGURATION ==========

PIEZOMETER_IMPORTS <- list(
  list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ01", id = "PZ01"),
  list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ02", id = "PZ02"),
  list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ03", id = "PZ03"),
  list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ04", id = "PZ04"),
  list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ05", id = "PZ05"),
  list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ06", id = "PZ06"),
  list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ07", id = "PZ07"),
  list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ08", id = "PZ08"),
  list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ09", id = "PZ09"),
  list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ10", id = "PZ10"),
  list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ11", id = "PZ11"),
  list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ12", id = "PZ12")
)
  
  
  
  
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

# Temporal Continuity - Timing/Gap test 
MIN_INTERVAL_MINUTES <- 15
MAX_GAP_HOURS <- 24

DATE_COLUMN <- "Datum.Zeit..GMT.05.00" # Original Column name after .csv conversion


# variables old (substitude)
date_column <- "Date"        # Column name for time stamp
id_column <- "ID"         # Column for identification (e.g. PZ01_01m PZ01_02, PZ02_01 (...))
sensor_group_column <- "sensor_group" # One level above id_column for identification (e.g. PZ01, PZ02 (...))
output_column <- "time_diff" # Column for calculated output
timediff_column <- "time_diff" # Column for further analysis in the field of temporal consistency
measurement_columns <- c("Abs_pres", "Temp")
maintenance_info_columns <- c("Connection_off", "Connection_on", "Host_connected", "Data_end")





SUM_FLAGS_COLUMN <- "sum_test"

RECORD_TOLERANCE <- 1

# Tolerance Test - Range Test
ABS_PRES_MIN <- 0    # kPa
ABS_PRES_MAX <- 200  # kPa
TEMP_MIN <- -10      # °C
TEMP_MAX <- 40       # °C
# Apply QC Flags function colum name
RT_FLAGS_COLUMN <- "range_test"


# Temporal consistency - Step Test
# Apply QC Flags function colum name
ST_FLAGS_COLUMN1 <- "step_test"


# Temporal Consistency - Persistence Test
RECORD_TOLERANCE <- 1
RECORD_TIME_TOLERANCE <- 60 # minutes
DUPLICATE_CHECK_COLS <- c("Date", "ID", "Abs_pres", "Temp")
# Apply QC Flags function colum name
PT_FLAGS_COLUMN <- "persistence_test"

# Internal Consistency Test
LOGICAL_CONDITION <- ""
# Apply QC Flags function colum name
IC_FLAGS_COLUMN <- "internal_consistency"

# apply qc flags workflow
ALLOWED_QC_LEVELS <- c(
  "range_test",
  "tc_step_test",
  "tc_persistence_test",
  "internal_consistency",
)

merge_column <- "RECORD"
merge_block_logic_column <- "final_block_id"


# ------------------------------------------------------------------------------
# LOG FILE PATHS 
# ------------------------------------------------------------------------------

LOG_TEMPORAL <- file.path(DIR_LOGS, "qc_log_temporal_consistency.csv")
LOG_PHYSICAL <- file.path(DIR_LOGS, "qc_log_physical_plausibility.csv")
LOG_DUPLICATES <- file.path(DIR_LOGS, "qc_log_duplicates.csv")
LOG_SUMMARY <- file.path(DIR_LOGS, "qc_summary_report.csv")

# ------------------------------------------------------------------------------
# Output intermediate variables
# ------------------------------------------------------------------------------



