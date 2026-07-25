#======================================================================
# Scriptname: 00_clean_qq_raw.R
# Goal(s): 
  # import .csv data
  # harmonization colum names
  # hormonization date column change Date format to POSIXct
  # Add station ID
  # export standardized .csv files for further QC steps
# Author: Kai Albert Zwießler
# Date: 2026.06.12
# Input Dataset: 
# Output: 
  # standardized .csv data for station Quelccaya from SENAMHI
#======================================================================



datapaths <- list.files(
  path = METEO_SENSOR_IMPORTS$STATION_QQ$FOLDER,
  pattern = "\\.xlsx$",
  full.names = TRUE
)
datapaths_named <- setNames(datapaths, basename(datapaths))

data_qq <- map_dfr(
  datapaths_named,
  ~ read_excel(.x),
  .id = "Source.Code"
)

# Column-type synchronization to prevent errors in the bind_rows workflow
data_qq <- data_qq %>%
  mutate(across(c(AirTC, Precip_Tot, RH, WD, WS, WS_Max), as.character))
# remove not required columns
data_qq <- drop_columns(data_qq, column_selection = METEO_SENSOR_IMPORTS$STATION_QQ$DROP_COLUMNS_FINAL)

# Rename function according to rename map
data_qq <- rename_columns(data_qq, rename_map = COLUMN_RENAME_MAP_QQ)

# Add ID column
data_qq <- data_qq %>%
  mutate(ID = METEO_SENSOR_IMPORTS$STATION_QQ$ID)


 
