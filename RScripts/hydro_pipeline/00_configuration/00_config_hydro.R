#=================================================================================================================
# Scriptname: 00_config_hydro.R
# Goal(s): 
  # Provides the required parameters for the hydrological data
# Author: Kai Albert Zwießler
# Date: 2025.12.24
#=================================================================================================================
# ==============================================================================
# HYDRO QC PIPELINE - CONFIGURATION
# ==============================================================================

#------------------------------------------------------------------------------
# IMPORT Section
# -----------------------------------------------------------------------------
HYDRO_SENSOR_IMPORTS <- list(
  WLS_O = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\waterlevel_outlet\\outlet_input_data",
               keep_files = c("21826515_QK_salida_25_02_2025.csv", "21826515_QK_salida_19_11_25.csv",
                              "21826515_QK_salida_24_03_26.csv"), id = "WLS_O"),
  WLS_L = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\waterlevel_lagoon\\lagoon_input_data",
               keep_files = c("21826493_QK_lag_24_02_25.csv", "21826493_QK_lag_14_08_25.csv", "21826493_QK_lag_20_11_25.csv"), id = "WLS_L"),
  PZ1  = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ01",
              keep_files = NULL, id = "PZ01"),
  PZ2  = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ02", 
              keep_files = NULL, id = "PZ02"),
  PZ3  = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ03", 
              keep_files = NULL, id = "PZ03"),
  PZ4  = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ04", 
              keep_files = NULL, id = "PZ04"),
  PZ5  = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ05", 
              keep_files = NULL, id = "PZ05"),
  PZ6  = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ06", 
              keep_files = NULL, id = "PZ06"),
  PZ7  = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ07", 
              keep_files = NULL, id = "PZ07"),
  PZ8  = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ08", 
              keep_files = NULL, id = "PZ08"),
  PZ9  = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ09", 
              keep_files = NULL, id = "PZ09"),
  PZ10 = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ10", 
              keep_files = NULL, id = "PZ10"),
  PZ11 = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ11", 
              keep_files = NULL, id = "PZ11"),
  PZ12 = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ12", 
              keep_files = NULL, id = "PZ12"),
  BAROM = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\barometer_data\\baro_input_data", 
               keep_files = c("21826507_QK_baro_06_08_24.csv", "21826507_QK_baro_12_11_24.csv", "21826507_QK_baro_24_02_25.csv",
                              "21826507_QK_baro_19_11_25.csv", "21826507_QK_baro_24_03_26.csv"), id = "BAROM")
)
# Equal Import-Parameters for all sensors
HYDRO_DATE_COLUMN <- "Datum.Zeit..GMT.05.00" # Original Column name after .csv conversion
HYDRO_DROP_COLUMNS_FINAL <- c("Datum.Zeit..GMT.05.00", "Record")
TIMEZONE_DATA <- "America/Lima"
TIMEZONE_PROCESS <- "Europe/Berlin"

# Column names hydrological sensors for rename_columns() old column = new column
HYDRO_COLUMN_RENAME_MAP <- c(
  "Anz."               = "Record",
  "Abs.Druck..kPa"     = "Abs_pres",
  "Temp....C"          = "Temp",
  "Koppler.abgetrennt" = "Connection_off",
  "Koppler.verbunden"  = "Connection_on",
  "Host.verbunden"     = "Host_connected",
  "Dateiende"          = "Data_end"
)

# Generate global missing codes among every data set
HYDRO_MISSING_CODES <- c(
    "",
    " ",
    "S/D",
    "-999",
    "-888.88",
    "-888.9",
    "N/A"
  )

# Harmonization of column order and column types.
HYDRO_COLUMN_ORDER_TYPES <- list(
  Date           = "POSIXct",
  ID             = "character",
  Abs_pres       = "numeric",
  Temp           = "numeric",
  Connection_off = "character",
  Connection_on  = "character",
  Host_connected = "character",
  Data_end       = "character",
  Angehalten     = "character",
  Source.Code    = "character"
)

# Measurement Column determination
HYDRO_MEASUREMENT_COLUMNS <- c(
  "Abs_pres",
  "Temp"
)

HYDRO_INFO_COLUMNS <- c(
  "Connection_off",
  "Connection_on",
  "Host_connected",
  "Data_end",
  "Stop"
)

# temporal aggregation 15 -> 60 minutes f.e.
HYDRO_AGGREGATION_FUNCTIONS <- list(
  Abs_pres   = "mean",
  Temp       = "mean"
)

#------------------------------------------------------------------------------
# QC Preparation Steps
# -----------------------------------------------------------------------------
# Identification of maintenance and data collection events




#------------------------------------------------------------------------------
# QC Parametrization
# -----------------------------------------------------------------------------
HYDRO_QC_CONFIG <- list(
  completeness_test = list(
    WLS_O = list(deployed = as.POSIXct("2025-01-15", tz = "America/Lima"), interval_min = 10),
    PZ01  = list(deployed = as.POSIXct("2025-04-03", tz = "America/Lima"), interval_min = 10)
  ),
  
  timing_gap_test = list(
    WLS_O = list(deployed = as.POSIXct("2025-01-15", tz = "America/Lima"), interval_min = 10),
    PZ01  = list(deployed = as.POSIXct("2025-04-03", tz = "America/Lima"), interval_min = 10)
  ),
  
  range_test = list(
    HYDRO_DEVICES_THRESHOLD = list(temp_threshold = c(min = 0, max = 40), PRES_THRESHOLD = c(min = 69, max = 207)),
    PZ01  = list(water_level = c(min = 0, max = 3.0))
  ),
  
  step_test = list(
    WLS_O = list(water_level = 0.5),
    PZ01  = list(water_level = 0.3)
  ),
  
  persistence_test = list(
    WLS_O = list(window = 6),
    PZ01  = list(window = 6)
  ),
  
  internal_consistency_test = list(
    WLS_O = list(Expression X>X>X),
    PZ01  = list(...elt())
  )
)



#------------------------------------------------------------------------------
# QC Flagging & Documentation
# -----------------------------------------------------------------------------
# QC flags workflow Parameter
QC_FLAG_CONFIG <- list(
ALLOWED_QC_LEVELS = c("completeness_test", "timing_gap_test",
  "range_test", "step_test", "persistence_test", "internal_consistency",
  ),
LOGS = 
)
# Metadata
SENSOR_UNITS <- list(Abs_pres = "kPa", Temp = "°C")

# WLS Serial Number
SENSOR_SN_WLS <- list(
  WLS_O_SN = "21826515",
  WLS_L_SN = "21826493"
  
)
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
  PZ12_SN = "21826503"
  )
SENSOR_SN_BARO <- "21826507"


#------------------------------------------------------------------------------
# EXPORT Section
# -----------------------------------------------------------------------------
HYDRO_OUTPUT_DIRECTORIES <- list(
  DIR_LOGS = "results/hydro_pipeline/logs", DIR_CHECKPOINTS = "results/hydro_pipeline/pipeline_debugging",
  DIR_PLOTS = "results/hydro_pipeline/plots", DIR_TEMPORAL_RESULTS = "results/temporal", DIR_TABLES = "results/hydro_pipeline/tables"
)


  
#------------------------------------------------------------------------------
# Parameter
# -----------------------------------------------------------------------------
  
  
  

# ====== LOAD & STANDARDIZE WORKFLOWs CONFIGURATION ======
# ------------------------------------------------------------------------------
# IMPORT SETTINGS
# ------------------------------------------------------------------------------ 

  SHEET_NAME <- "Rinput"
# ===================================



# ------------------------------------------------------------------------------
# QC PARAMETERS
# ------------------------------------------------------------------------------

# Temporal Continuity - Timing/Gap test 
MIN_INTERVAL_MINUTES <- 15
MAX_GAP_HOURS <- 24




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



