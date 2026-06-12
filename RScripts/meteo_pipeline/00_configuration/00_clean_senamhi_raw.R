#======================================================================
# Scriptname: 00_clean_senamhi_raw.R
# Goal(s): 
  # import .csv and .xlsx historical data
  # harmonization colum names
  # hormonization date column change Date format to POSIXct
  # Add station ID
  # join .xlsx and .csv
  # export standardized .csv files for further QC steps
# Author: Kai Albert Zwießler
# Date: 2026.06.01
# Input Dataset: 
# Output: 
  # standardized .csv data for each met. station of SENAMHI

# Data import individual files .csv and .xlsx
# Using build function for data import
data_qp <- load_senamhi_csv(
  folder_path = METEO_SENSOR_IMPORTS$STATION_QP$folder,
)
data_sc <- load_senamhi_csv(
  folder_path = METEO_SENSOR_IMPORTS$STATION_SC$folder,
)
data_cb <- load_senamhi_csv(
  folder_path = METEO_SENSOR_IMPORTS$STATION_CB$folder,
)
# Import .xlsx
data_xlsx_qp <- read_excel(SENAMHI_XLSX_IMPORTS$STATION_QP$file, sheet = SENAMHI_XLSX_IMPORTS$STATION_QP$sheet_name)
data_xlsx_sc <- read_excel(SENAMHI_XLSX_IMPORTS$STATION_SC$file, sheet = SENAMHI_XLSX_IMPORTS$STATION_SC$sheet_name)
data_xlsx_cb <- read_excel(SENAMHI_XLSX_IMPORTS$STATION_CB$file, sheet = SENAMHI_XLSX_IMPORTS$STATION_CB$sheet_name)

# Column-type synchronization .csv and .xlsx for CARABAYA, adressing differences in colum types
data_xlsx_cb <- data_xlsx_cb %>%
  mutate(across(c(AirTC, Precip_Tot, RH, WD, WS), as.character))
# Ranme columns international standard names (see rename_map)
data_qp <- rename_columns(data_qp, rename_map = COLUMN_RENAME_MAP_SENAMHI) # rename columns according to rename_map, defined in the configuration file
data_sc <- rename_columns(data_sc, rename_map = COLUMN_RENAME_MAP_SENAMHI)
data_cb <- rename_columns(data_cb, rename_map = COLUMN_RENAME_MAP_SENAMHI)

data_xlsx_qp <- rename_columns(data_xlsx_qp, rename_map = COLUMN_RENAME_MAP_SENAMHI_XLSX) # rename columns according to rename_map, defined in the configuration file
data_xlsx_sc <- rename_columns(data_xlsx_sc, rename_map = COLUMN_RENAME_MAP_SENAMHI_XLSX)
data_xlsx_cb <- rename_columns(data_xlsx_cb, rename_map = COLUMN_RENAME_MAP_SENAMHI_XLSX)



# concatenate data and time column for all data
data_qp <- data_qp %>%
  mutate(Date = paste(Date_raw, Time_raw)
  )
data_sc <- data_sc %>%
  mutate(Date = paste(Date_raw, Time_raw)
  )
data_cb <- data_cb %>%
  mutate(Date = paste(Date_raw, Time_raw)
  )

# unite date column and time column + date column conversion to POSIXct and ISO format.
data_qp <- data_qp %>%
  mutate(
    Date = ymd_hm(
      Date,
      tz = TIMEZONE_DATA
    )
  )
data_sc <- data_sc %>%
  mutate(
    Date = ymd_hm(
      Date,
      tz = TIMEZONE_DATA
    )
  )
data_cb <- data_cb %>%
  mutate(
    Date = ymd_hm(
      Date,
      tz = TIMEZONE_DATA
    )
  )

# 

# removing raw date & time for bind_rows preparation
data_qp <- data_qp %>%
  select(-Date_raw, -Time_raw)
data_sc <- data_sc %>%
  select(-Date_raw, -Time_raw)
data_cb <- data_cb %>%
  select(-Date_raw, -Time_raw)
# Removing RECORD column for bind_rows preparation
data_xlsx_qp <- data_xlsx_qp %>%
  select(-RECORD)
data_xlsx_sc <- data_xlsx_sc %>%
  select(-RECORD)
data_xlsx_cb <- data_xlsx_cb %>%
  select(-RECORD)
# Add column named source.code to keep the information about the historical excel files and the newer .csv files
data_xlsx_qp <- data_xlsx_qp %>%
  mutate(Source.Code = "QUISOQUEPINA_joined.xslx")
data_xlsx_sc <- data_xlsx_sc %>%
  mutate(Source.Code = "SIBINACHOCHA_joined.xlsx")
data_xlsx_cb <- data_xlsx_cb %>%
  mutate(Source.Code = "CARABAYA_joined.xlsx")

# Join data sets
data_qp_joined <- bind_rows(
  data_xlsx_qp,
  data_qp
)
data_sc_joined <- bind_rows(
  data_xlsx_sc,
  data_sc
)
data_cb_joined <- bind_rows(
  data_xlsx_cb,
  data_cb
)

# Sort mechanism
data_qp_joined <- data_qp_joined %>%
  arrange(Date)
data_sc_joined <- data_sc_joined %>%
  arrange(Date)
data_cb_joined <- data_cb_joined %>%
  arrange(Date)

# Add ID column
data_qp_joined <- data_qp_joined %>%
  mutate(ID = METEO_SENSOR_IMPORTS$STATION_QP$id)
data_sc_joined <- data_sc_joined %>%
  mutate(ID = METEO_SENSOR_IMPORTS$STATION_SC$id)
data_cb_joined <- data_cb_joined %>%
  mutate(ID = METEO_SENSOR_IMPORTS$STATION_CB$id)

# Make date format explicit to prevent missing time records for midnight.
data_qp_joined <- data_qp_joined %>%
  mutate(
    Date = format(Date, "%Y-%m-%d %H:%M:%S")
  )
data_sc_joined <- data_sc_joined %>%
  mutate(
    Date = format(Date, "%Y-%m-%d %H:%M:%S")
  )
data_cb_joined <- data_cb_joined %>%
  mutate(
    Date = format(Date, "%Y-%m-%d %H:%M:%S")
  )

# Export data sets
write.csv(
  data_qp_joined,
  file = file.path(
    SENAMHI_XLSX_IMPORTS$STATION_QP$export,
    "00_QP_input.csv"
  ),
  row.names = FALSE # row.names = FALSE to export without adding a RECORD column (row numbers)
)
write.csv(
  data_sc_joined,
  file = file.path(
    SENAMHI_XLSX_IMPORTS$STATION_SC$export,
    "00_SC_input.csv"
  ),
  row.names = FALSE
)
write.csv(
  data_cb_joined,
  file = file.path(
    SENAMHI_XLSX_IMPORTS$STATION_CB$export,
    "00_CB_input.csv"
  ),
  row.names = FALSE
)