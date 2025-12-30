#=================================================================================================================
# Scriptname: 00_config_meteorological.R
# Goal(s): 
# Provides meteorological scripts and workflows with its specific configuration
# Author: Kai Albert Zwießler
# Date: 2025.12.24
#=================================================================================================================

# ====== LOAD & STANDARDIZE WORKFLOWs CONFIGURATION ======
# ==========  ==========
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
# Metadata parameters
sensor_units <- list(AirTC = "°C", RH = "%", Precip_Tot = "mm", WS = "m/s", WS_Max = "m/s", WD = "°", Dewp = "°C")
Sensor_information <- list(
  AirTC/RH_S-THC-M008_SN = "21666169",
  Rain_Gauge_HOBO_S-RGB-M002_SN = "21673752",
  Wind_HOBO_S-WCF-M003_SN = "21742435")


# Process Parameters temporal consistency
date_column <- "Date"        # Column name for timestamp
id_column <- "ID"         # Column for device identification
maintenance_info_columns <- c()
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