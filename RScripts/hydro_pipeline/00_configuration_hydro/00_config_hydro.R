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
HYDRO_IMPORT_FRAMEWORK <- list(
  DATE_COLUMN = "Datum.Zeit..GMT.05.00" , DROP_COLUMNS_FINAL = c("Datum.Zeit..GMT.05.00", "Record", "Angehalten")
  )
  
HYDRO_SENSOR_IMPORTS <- list(
  WLS_O = list(FOLDER = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\waterlevel_outlet\\outlet_input_data",
               KEEP_FILES = c("21826515_QK_salida_25_02_2025.csv", "21826515_QK_salida_19_11_25.csv",
                              "21826515_QK_salida_24_03_26.csv"), ID = "WLS_O"),
  WLS_L = list(FOLDER = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\waterlevel_lagoon\\lagoon_input_data",
               KEEP_FILES = c("21826493_QK_lag_24_02_25.csv", "21826493_QK_lag_14_08_25.csv", "21826493_QK_lag_20_11_25.csv"), ID = "WLS_L"),
  PZ1  = list(FOLDER = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ01",
              KEEP_FILES = NULL, ID = "PZ01"),
  PZ2  = list(FOLDER = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ02", 
              KEEP_FILES = NULL, ID = "PZ02"),
  PZ3  = list(FOLDER = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ03", 
              KEEP_FILES = NULL, ID = "PZ03"),
  PZ4  = list(FOLDER = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ04", 
              KEEP_FILES = NULL, ID = "PZ04"),
  PZ5  = list(FOLDER = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ05", 
              KEEP_FILES = NULL, ID = "PZ05"),
  PZ6  = list(FOLDER = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ06", 
              KEEP_FILES = NULL, ID = "PZ06"),
  PZ7  = list(FOLDER = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ07", 
              KEEP_FILES = NULL, ID = "PZ07"),
  PZ8  = list(FOLDER = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ08", 
              KEEP_FILES = NULL, ID = "PZ08"),
  PZ9  = list(FOLDER = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ09", 
              KEEP_FILES = NULL, ID = "PZ09"),
  PZ10 = list(FOLDER = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ10", 
              KEEP_FILES = NULL, ID = "PZ10"),
  PZ11 = list(FOLDER = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ11", 
              KEEP_FILES = NULL, ID = "PZ11"),
  PZ12 = list(FOLDER = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\piezometer_data\\PZ12", 
              KEEP_FILES = NULL, ID = "PZ12"),
  BAROM = list(FOLDER = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\Hydrological_data\\barometer_data\\baro_input_data", 
               KEEP_FILES = c("21826507_QK_baro_06_08_24.csv", "21826507_QK_baro_12_11_24.csv", "21826507_QK_baro_24_02_25.csv",
                              "21826507_QK_baro_19_11_25.csv", "21826507_QK_baro_24_03_26.csv"), ID = "BAROM")
  )


# Import Framework for all sensors
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
  Source.Code    = "character"
)

# Hydro Master DF pre standardization
HYDRO_MASTER_DF_FRAMEWORK <- list(
  DATE_COLUMN = "Date", SOURCE_COLUMN_STATION = "ID", SOURCE_COLUMN_FILE = "Source.Code",
  MEASUREMENT_COLUMNS = c("Abs_pres", "Temp"), INFO_COLUMNS = c("Connection_off", "Connection_on", "Host_connected", "Data_end", "Stop"),
  SOURCE_IDS15 = c("21826493_QK_lag_14_08_25.csv", "21826493_QK_lag_20_11_25.csv", "21826507_QK_baro_19_11_25.csv",
                   "21826507_QK_baro_24_03_26.csv", "21826515_QK_salida_19_11_25.csv", "21826515_QK_salida_24_03_26.csv",
                   "PZ01_02_14_08_2025_21826509.csv", "PZ02_02_14_08_2025_21826502.csv", "PZ03_02_14_08_2025_21826497.csv",
                   "PZ04_02_14_08_2025_21826519.csv", "PZ05_02_14_08_2025_21826512.csv", "PZ06_02_14_08_2025_21826504.csv",
                   "PZ07_02_14_08_2025_21826505.csv", "PZ08_02_14_08_2025_21826496.csv", "PZ09_02_14_08_2025_21826494.csv",
                   "PZ10_02_14_08_2025_21826516.csv", "PZ11_02_14_08_2025_21826500.csv", "PZ12_02_14_08_2025_21826503.csv")
)

# Master DF after load and standardization
HYDRO_MASTER_DF_STANDARDIZED <- list(
  TIME_STEP15 = "15 min",
  TEMPORAL_AGGREGATION_FUNCTIONS = c(Abs_pres = "mean", Temp = "mean"), MIN_COVERAGE_AGGREGATION = 0.5
  )
  


#------------------------------------------------------------------------------
# QC Parametrization
# -----------------------------------------------------------------------------
# Completeness test
HYDRO_QC_CONFIG <- list(
  COMPLETENESS_TEST = list(
    FLAG_VALUE = "MISSING_VALUE"
  ),
  RANGE_TEST = list(
    
  )
)

# QC Tests executed in the pipeline workflow
ALLOWED_QC_TESTS <- names(HYDRO_QC_CONFIG) # derived from Hydro QC config.



# Next Test

#------------------------------------------------------------------------------
# QC Flagging Workflow & Documentation
# -----------------------------------------------------------------------------


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
HYDRO_OUTPUT_FILES <- list(
  HARMONIZATION_LOG = "results/hydro_pipeline/logs/harmonization_log.csv", QC_LOG = "results/hydro_pipeline/logs/qc_log.csv",
  QC_SUMMARY = "results/hydro_pipeline/logs/qc_summary.csv")

HYDRO_OUTPUT_DIRECTORIES <- list(
  DIR_RESULTS = "results/hydro_pipeline",
  DIR_LOGS = "results/hydro_pipeline/logs", DIR_CHECKPOINTS = "results/hydro_pipeline/pipeline_debugging",
  DIR_PLOTS = "results/hydro_pipeline/plots", DIR_TEMPORAL_RESULTS = "results/temporal", DIR_TABLES = "results/hydro_pipeline/tables"
)



#------------------------------------------------------------------------------
# QC Parametrization
# -----------------------------------------------------------------------------
HYDRO_QC_PARAMS <- list(
  DATA15 = list(
    max_gap_min = 30,  max_rate_of_change = c(Abs_pres = 5,  Temp = 2)
  ),
  DATA60 = list(
    max_gap_min = 120, max_rate_of_change = c(Abs_pres = 15, Temp = 6)
  )
)

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
    WLS_O = Expression,
    PZ01  = list(...elt())
  ))







