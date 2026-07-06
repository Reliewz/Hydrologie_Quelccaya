#=================================================================================================================
# Scriptname: 00_config_meteo.R
# Goal(s): 
  # Provides meteorological scripts and workflows with its specific configuration
# Author: Kai Albert Zwießler
# Date: 2025.12.24
#=================================================================================================================

#------------------------------------------------------------------------------
# Import Section
# -----------------------------------------------------------------------------
METEO_SENSOR_IMPORTS <- list(
  STATION_QK = list(
    FOLDER = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\STATION_QORIKALIS\\meteo_input_data",
    KEEP_FILES = c("2_QORIKALIS_20_12_2023.csv", "3_QORIKALIS_30_04_24.csv", "4_QORIKALIS_04_06_24.csv", "5_QORIKALIS_06_08_2024.csv",
                   "6_QORIKALIS_12_11_2024.csv", "7_QORIKALIS_24_02_2025.csv", "8_QORIKALIS_22_06_2025.csv", "9_QORIKALIS_07_07_2025.csv",
                   "10_QORIKALIS_18_08_2025.csv"),
    ID = "QK", DATE_COLUMN = "Date_raw", DROP_IMPORT_COLUMNS_QK = c("Total: Regen, mm", "Total: Lluvia, mm"), DROP_COLUMNS_FINAL = c("Record", "Date_raw")),
  STATION_QQ = list(
    FOLDER = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\STATION_QUELCCAYA\\meteo_input_data",
    KEEP_FILES = NULL, ID = "QQ", DATE_COLUMN = "Date", DROP_COLUMNS_FINAL = c("SlrW", "SlrW_Max", "SlrW_Avg", "SnDep", "RECORD", "Tot24")),
  STATION_QP = list(
    IMPORT_XLSX = 
      "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\STATION_QUISOQUEPINA_N\\QUISOQUEPINA_edited\\Power_Quiery_edit\\QUISOQUEPINA_joined.xlsx",
    SHEET_NAME = "Rinput",
    FOLDER_CSV = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\STATION_QUISOQUEPINA_N\\meteo_input_data",
    KEEP_FILES = c("2024.09_QUISOQUEPINA.csv", "2024.10_QUISOQUEPINA.csv", "2024.11_QUISOQUEPINA.csv", 
                   "2024.12_QUISOQUEPINA.csv", "2025.01_QUISOQUEPINA.csv", "2025.02_QUISOQUEPINA.csv",
                   "2025.03_QUISOQUEPINA.csv", "2025.04_QUISOQUEPINA.csv", "2025.05_QUISOQUEPINA.csv",
                   "2025.06_QUISOQUEPINA.csv", "2025.07_QUISOQUEPINA.csv", "2025.08_QUISOQUEPINA.csv",
                   "2025.09_QUISOQUEPINA.csv", "2025.10_QUISOQUEPINA.csv",
                   "2025.11_QUISOQUEPINA.csv"), ID = "QP"),
  STATION_SC = list(
    IMPORT_XLSX = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\STATION_SIBINACHOCHA_W\\SIBINACHOCHA_edited\\Power_Quiery_edit\\SIBINACHOCHA_joined.xlsx",
    SHEET_NAME = "Rinput",
    FOLDER_CSV = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\STATION_SIBINACHOCHA_W\\meteo_input_data",
    KEEP_FILES = c("2024.09_SIBINACHOCHA.csv", "2024.10_SIBINACHOCHA.csv", "2024.11_SIBINACHOCHA.csv", 
                   "2024.12_SIBINACHOCHA.csv", "2025.01_SIBINACHOCHA.csv", "2025.02_SIBINACHOCHA.csv", 
                   "2025.03_SIBINACHOCHA.csv", "2025.04_SIBINACHOCHA.csv", "2025.05_SIBINACHOCHA.csv",
                   "2025.06_SIBINACHOCHA.csv", "2025.07_SIBINACHOCHA.csv", "2025.08_SIBINACHOCHA.csv", 
                   "2025.09_SIBINACHOCHA.csv", "2025.10_SIBINACHOCHA.csv","2025.11_SIBINACHOCHA.csv"), ID = "SC"),
  STATION_CB = list(
    IMPORT_XLSX = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\STATION_CARABAYA_O\\CARABAYA_edited\\Power_Quiery_edit\\CARABAYA_joined.xlsx",
    SHEET_NAME = "Rinput",
    FOLDER_CSV = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\STATION_CARABAYA_O\\meteo_input_data",
    KEEP_FILES = c("2024.09_CARABAYA.csv", "2024.10_CARABAYA.csv", "2024.11_CARABAYA.csv", "2024.12_CARABAYA.csv",
                   "2025.01_CARABAYA.csv", "2025.02_CARABAYA.csv", "2025.03_CARABAYA.csv", "2025.04_CARABAYA.csv", "2025.05_CARABAYA.csv",
                   "2025.06_CARABAYA.csv", "2025.07_CARABAYA.csv", "2025.08_CARABAYA.csv", "2025.09_CARABAYA.csv", "2025.10_CARABAYA.csv",
                   "2025.11_CARABAYA.csv"), ID = "CB")
  
)


# Master data frame
TIMEZONE_DATA <- "America/Lima"
TIMEZONE_PROCESS <- "Europe/Berlin"



# Rename map, used for ensure_required_columns function and rename_columns function
COLUMN_RENAME_MAP_QK <- c(
  "Anz." = "Record",
  "Datum Zeit, GMT-05:00" = "Date_raw",
  "Temp., °C" = "AirTC",
  "RH, %" = "RH",
  "Regen, mm" = "Precip",
  "Windgeschwindigkeit, m/s" = "WS",
  "Böengeschwindigkeit, m/s" = "Wind_gust",
  "Windrichtung, ø" = "WD",
  "TauPkt, °C" = "Dew_point",
  # Source Code listed for ensure_required_columns
  "Source.Code" = "Source.Code"
)

TRANSLATION_MAP_QK <- c(
  "N.º" = "Anz.",
  "Fecha Tiempo, GMT-05:00" = "Datum Zeit, GMT-05:00",
  "Temp, °C" = "Temp., °C",
  "HR, %" = "RH, %",
  "Lluvia, mm" = "Regen, mm",
  "Velocidad del viento, m/s" = "Windgeschwindigkeit, m/s",
  "Velocidad de Ráfagas, m/s" = "Böengeschwindigkeit, m/s",
  "Dirección del viento, ø" = "Windrichtung, ø",
  "Pt rocío, °C" = "TauPkt, °C",
  "Total: Lluvia, mm" = "Total: Regen, mm"
)

#Station Quelccaya
COLUMN_RENAME_MAP_QQ <- c(
  "Precip_Tot"         = "Precip",
  "WS_Max"             = "Wind_gust"
)

# Stations SENAMHI
COLUMN_RENAME_MAP_SENAMHI <- c(
  "AÑO...MES...DÍA"         = "Date_raw",
  "HORA"                    = "Time_raw",
  "TEMPERATURA...C."        = "AirTC",
  "PRECIPITACIÓN..mm.hora." = "Precip",
  "HUMEDAD...."             = "RH",
  "DIRECCION.DEL.VIENTO...."= "WD",
  "VELOCIDAD.DEL.VIENTO..m.s." = "WS"
)
COLUMN_RENAME_MAP_SENAMHI_XLSX <- c(
  "Precip_Tot" = "Precip"
)

# Generate global missing codes among every data set
METEO_MISSING_CODES <- c(
  "",
  " ",
  "S/D",
  "-999",
  "-888.88",
  "-888.9",
  "N/A"
)

# Harmonization of column order and column types.
METEO_COLUMN_ORDER_TYPES <- list(
  Date        = "POSIXct",
  ID          = "character",
  AirTC       = "numeric",
  RH          = "numeric",
  Precip      = "numeric",
  WS          = "numeric",
  Wind_gust   = "numeric",
  WD          = "numeric",
  Dew_point   = "numeric",
  Source.Code = "character"
)

# Master df framework
METEO_MASTER_DF_FRAMEWORK <- list(
  DATE_COLUMN = "Date", SOURCE_COLUMN_STATION = "ID", SOURCE_COLUMN_FILE = "Source.Code",
  METEO_MEASUREMENT_COLUMNS = c("AirTC", "RH", "Precip", "WS", "Wind_gust", "WD", "Dew_point")
)

# Master df standardized - temporal harmonization workflow
METEO_MASTER_DF_STANDARDIZED <- list(
  SOURCE_IDS15 = "10_QORIKALIS_18_08_2025.csv",
  AGGREGATION_FUNCTIONS = c(
    AirTC      = "mean",
    RH         = "mean",
    Precip     = "sum",
    WS         = "mean",
    Wind_gust  = "max",
    WD         = "vector_mean_wd", # the string must match the exact function name function_vector_mean_wd.
    Dew_point  = "mean"),
  MIN_COVERAGE_AGGREGATION = 0.5
)

METEO_MASTER_DF_HARMONIZED <- list(
  
)







#------------------------------------------------------------------------------
# Documentation of flagging and decision making
# -----------------------------------------------------------------------------

# apply qc flags executed tests
ALLOWED_QC_TESTS <- c(
  "range_test",
  "step_test",
  "persistence_test",
  "internal_consistency",
  "summarization_test"
)
# List where records inside the pipeline will be stored for final master_log bind_row execution
qc_logs <- list()

#------------------------------------------------------------------------------
# EXPORT Section
# -----------------------------------------------------------------------------
METEO_OUTPUT_FILES <- list(
  HARMONIZATION_LOG = "results/meteo_pipeline/logs/harmonization_log.csv", QC_LOG = "results/meteo_pipeline/logs/qc_log.csv",
  QC_SUMMARY = "results/meteo_pipeline/logs/qc_summary.csv")

METEO_OUTPUT_DIRECTORIES <- list(
  DIR_RESULTS = "results/meteo_pipeline", DIR_LOGS = "results/meteo_pipeline/logs",
  DIR_CHECKPOINTS = "results/meteo_pipeline/pipeline_debugging",
  DIR_PLOTS = "results/meteo_pipeline/plots", DIR_TEMPORAL_RESULTS = "results/temporal", DIR_TABLES = "results/meteo_pipeline/tables")

#------------------------------------------------------------------------------
# QC Parametrization
# -----------------------------------------------------------------------------
METEO_QC_CONFIG <- list(
  completeness_test = list(
    STATION_QK = list(deployed = as.POSIXct("2025-01-15", tz = "America/Lima"), interval_min = 10),
    STATION_QQ  = list(deployed = as.POSIXct("2025-04-03", tz = "America/Lima"), interval_min = 10),
    STATION_QUISIQUEPINA  = list(deployed = as.POSIXct("2025-04-03", tz = "America/Lima"), interval_min = 10),
    STATION_CARABAYA  = list(deployed = as.POSIXct("2025-04-03", tz = "America/Lima"), interval_min = 10),
    STATION_SIBINACHOCHA  = list(deployed = as.POSIXct("2025-04-03", tz = "America/Lima"), interval_min = 10),
  ),
  
  timing_gap_test = list(
    STATION_QK = list(deployed = as.POSIXct("2025-01-15", tz = "America/Lima"), interval_min = 10),
    STATION_QQ = list(deployed = as.POSIXct("2025-01-15", tz = "America/Lima"), interval_min = 10),
    STATION_QUISIQUEPINA = list(deployed = as.POSIXct("2025-01-15", tz = "America/Lima"), interval_min = 10),
    STATION_CARABAYA = list(deployed = as.POSIXct("2025-01-15", tz = "America/Lima"), interval_min = 10),
    STATION_SIBINACHOCHA = list(deployed = as.POSIXct("2025-01-15", tz = "America/Lima"), interval_min = 10)
  ),
  
  range_test = list(
    METEO_RANGE_THRESHOLDS = list(temp_range = c(min = -20, max = 50), precip_range = c(min = 69, max = 207), RH_range = c(min = 0, max = 100)), WS_range = c(min = 0, max_qk = 76), WD_range = c(min = 0, max = 355)
  ),
  
  step_test = list(
    STATION_QK = list(water_level = 0.5),
    PZ01  = list(water_level = 0.3)
  ),
  
  persistence_test = list(
    METEO_PERSISTANCE_THRESHOLD = list(window = 6),
    PZ01  = list(window = 6)
  ),
  
  internal_consistency_test = list(
    METEO_CONDITIONS = list(temp_exp = X>X), (precip_exp = XXXX), (RH_exp = X), (WS_exp = XX))
    )



# Metadata
SENSOR_UNITS <- list(AirTC = "°C", RH = "%", Precip_Tot = "mm", WS = "m/s", WS_Max = "m/s", WD = "°", Dewp = "°C")
SENSOR_SN_QK <- c(
  `AirTC/RH_S-THC-M008_SN` = "21666169",
  `Rain_Gauge_HOBO_S-RGB-M002_SN` = "21673752",
  `Wind_HOBO_S-WCF-M003_SN` = "21742435")