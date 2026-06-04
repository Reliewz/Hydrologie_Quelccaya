#=================================================================================================================
# Scriptname: 00_config_meteorological.R
# Goal(s): 
# Provides meteorological scripts and workflows with its specific configuration
# Author: Kai Albert Zwießler
# Date: 2025.12.24
#=================================================================================================================

#------------------------------------------------------------------------------
# Import Section
# -----------------------------------------------------------------------------
METEO_SENSOR_IMPORTS <- list(
  STATION_QK = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\STATION_QORIKALIS\\meteo_input_data",
               keep_files = c(
                 "2_QORIKALIS_20_12_2023.csv", "3_QORIKALIS_30_04_24.csv", "4_QORIKALIS_04_06_24.csv", "5_QORIKALIS_06_08_2024.csv",
                 "6_QORIKALIS_12_11_2024.csv", "7_QORIKALIS_24_02_2025.csv", "8_QORIKALIS_22_06_2025.csv",
                 "9_QORIKALIS_07_07_2025.csv", "10_QORIKALIS_18_08_2025.csv"), id = "QK"),
  STATION_QQ = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\STATION_QUISOQUEPINA_N\\meteo_input_data\\joined_dataset",
                    keep_files = NULL, id = "QQ"),
  STATION_QP = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\STATION_QUISOQUEPINA_N\\meteo_input_data",
                    keep_files = NULL, id = "QP"),
  STATION_SC = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\STATION_SIBINACHOCHA_W\\meteo_input_data\\joined_dataset",
                    keep_files = NULL, id = "SC"),
  STATION_CB = list(folder = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\STATION_CARABAYA_O\\meteo_input_data\\joined_dataset",
                    keep_files = NULL, id = "CB")
)

DATE_COLUMN <- "Datum.Zeit..GMT.05.00" # Original Column name after .csv conversion QK
TIMEZONE_DATA <- "America/Lima"
TIMEZONE_PROCESS <- "Europe/Berlin"



COLUMN_RENAME_MAP_QK <- c(
  "Anz."                     = "Record",
  "Datum.Zeit..GMT.05.00"    = "Date_raw",
  "Temp....C"                = "AirTC",
  "RH..."                    = "RH",
  "Regen..mm"                = "Precip",
  "Windgeschwindigkeit..m.s" = "WS",
  "Böengeschwindigkeit..m.s" = "Wind_gust",
  "Windrichtung..ø"          = "WD",
  "TauPkt...C"               = "Dew_point"
)


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
    METEO_CONDITIONS = list(temp_exp = X>X>X), (precip_exp = XXXX), (RH_exp = ), (WS_exp = XX)
    )
)


# Metadata
SENSOR_UNITS <- list(AirTC = "°C", RH = "%", Precip_Tot = "mm", WS = "m/s", WS_Max = "m/s", WD = "°", Dewp = "°C")
SENSOR_SN_QK <- list(
  AirTC/RH_S-THC-M008_SN = "21666169",
  Rain_Gauge_HOBO_S-RGB-M002_SN = "21673752",
  Wind_HOBO_S-WCF-M003_SN = "21742435")




#------------------------------------------------------------------------------
# EXPORT Section
# -----------------------------------------------------------------------------
METEO_OUTPUT_DIRECTORIES <- list(
  DIR_LOGS = "results/meteo_pipeline/logs", DIR_CHECKPOINTS = "results/meteo_pipeline/pipeline_debugging",
  DIR_PLOTS = "results/meteo_pipeline/plots", DIR_TEMPORAL_RESULTS = "results/temporal", DIR_TABLES = "results/meteo_pipeline/tables"
)


#Dataframe
input_file <- "D:/RProjekte/Hydrologie_Quelccaya/Datenquellen/STATION_QORIKALIS/Meteorological_data/processed/QORIKALIS_merged.xlsx"
#alternative paths: 
# STATION QUELCCAYA: "D:/RProjekte/Hydrologie_Quelccaya/Datenquellen/STATION_QUELCCAYA/Daten_meteorologisch/QUELCCAYA_merged.xlsx"
# STATION CAYABAYA: "D:/RProjekte/Hydrologie_Quelccaya/Datenquellen/STATION_CARABAYA_O/CARABAYA_joint.xlsx"
# STATION QUISOQUEPINA "D:/RProjekte/Hydrologie_Quelccaya/Datenquellen/STATION_QUISOQUEPINA_N/QUISOQUEPINA_joint.xlsx"
# STATION SIBINACHOCHA "D:/RProjekte/Hydrologie_Quelccaya/Datenquellen/STATION_SIBINACHOCHA_W/SIBINACHOCHA_joint.xlsx"




#Parameters
sheet_name <- "Rinput"
date_column <- "Date"        # Column name for timestamp
id_column <- "ID"         # Column for identification (e.g. PZ01_01m PZ01_02, PZ02_01 (...))

# ====== QALITY-CONTROL WORKFLOWs ======
# = TEMPORAL CONSISTENCY =

#Process Parameters
date_column <- "Date"        # Column name for timestamp
id_column <- "ID"         # Column for identification
output_column <- "time_diff" # Column for calculated output
timediff_column <- "time_diff" # Column for further analysis in the field of temporal consistency 
measurement_columns_qk <- c("AirTC", "RH", "Precip_Tot", "WS", "WS_Max", "WD", "DewP")
measurement_columns_qc <- c("AirTC", "RH", "Precip_Tot", "Tot24", "WS", "WD", "WS_Max", "SlrW", "Slrw_Max", "Slrw_Avg", "SnDep")
measurement_columns_sq <- c("AirTC", "Precip_Tot", "RH", "WS", "WD")
measurement_columns_cb <- c("AirTC", "Precip_Tot", "RH", "WS", "WD")
measurement_columns_qp <- c("AirTC", "Precip_Tot", "RH", "WS", "WD")



# apply qc flags workflow
QC_LEVELS <- c(
  "temporal_consistency",
  "physical_plausibility"
)
merge_column <- "RECORD"
# Workflow Parameters:
record_tolerance <- 1