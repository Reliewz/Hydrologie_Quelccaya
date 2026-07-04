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
# Import Framework for all sensors
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

# Hydro Master DF pre standardization
HYDRO_MASTER_DF_FRAMEWORK <- list(
  DATE_COLUMN = "Date", STATION_ID = "ID", SOURCE_COLUMN = "Source.Code",
  MEASUREMENT_COLUMNS = c("Abs_pres", "Temp"), INFO_COLUMNS = c("Connection_off", "Connection_on", "Host_connected", "Data_end", "Stop")
)

# Master DF after load and standardization
HYDRO_MASTER_DF_STANDARDIZED <- list(
  TEMPORAL_AGGREGATION_FUNCTIONS = c(Abs_pres = "mean", Temp = "mean"), MIN_COVERAGE_AGGREGATION = 0.5, SOURCE_COLUMN = "Source.Code", 
  SOURCE_COLUMN_FILES = "Source.Code", 
  SOURCE_IDS_15 = c("21826493_QK_lag_14_08_25.csv", "21826493_QK_lag_20_11_25.csv", "21826507_QK_baro_19_11_25.csv",
                    "21826507_QK_baro_24_03_26.csv", "21826515_QK_salida_19_11_25.csv", "21826515_QK_salida_24_03_26.csv",
                    "PZ01_02_14_08_2025_21826509.csv", "PZ02_02_14_08_2025_21826502.csv", "PZ03_02_14_08_2025_21826497.csv",
                    "PZ04_02_14_08_2025_21826519.csv", "PZ05_02_14_08_2025_21826512.csv", "PZ06_02_14_08_2025_21826504.csv",
                    "PZ07_02_14_08_2025_21826505.csv", "PZ08_02_14_08_2025_21826496.csv", "PZ09_02_14_08_2025_21826494.csv",
                    "PZ10_02_14_08_2025_21826516.csv", "PZ11_02_14_08_2025_21826500.csv", "PZ12_02_14_08_2025_21826503.csv")
                                    )


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
    WLS_O = Expression,
    PZ01  = list(...elt())
  ))



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



