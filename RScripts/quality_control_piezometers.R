#======================================================================
# Scriptname: quality_control_piezometers.R
# Goal(s): 
  # Documentation of steps taken in Power Quiery
  # Change Date format to (...)
  # Time step adjustment to hourly values
# Author: Kai Albert Zwießler
# Date: 2025.11.14
# Input Dataset: Hydrological_data/piezometer_data/PZ_merged/PZ_merged/All_PZ_merged.xlsx
# Outputs: 
  # figures/temperature_timeseries.png	#
# Units:
  # Abs.pres <- kPa
  # Temp <- °C
# Sensor information:
  # PZ01  S/N: 21826509
  # PZ02  S/N: 21826502
  # PZ03  S/N: 21826497
  # PZ04  S/N: 21826519
  # PZ05  S/N: 21826512
  # PZ06  S/N: 21826504
  # PZ07  S/N: 21826505
  # PZ08  S/N: 21826596
  # PZ09  S/N: 21826594
  # PZ010 S/N: 21826516
  # PZ011 S/N: 21826500
  # PZ12  S/N: 21826503

#======================================================================
##Documentation of Power Quiery steps##
# All Piezometer data has been loaded from one folder.
# First column removed
# Correct column assigned as headlines
# Changed column names.
# Adding customized column to convert the date from US to format: YYYY-MM-DD hh:mm:ss
# = DateTime.FromText([#"Date Time, GMT-5:00"], "en-US")
# = DateTime.ToText([Date_Standardized], "yyyy-MM-dd HH:mm:ss")
# Changing order of column & removing old Date column
# Changing type to decimal with location information "English (USA)"
# Assigning a Source.Name to every line
# Extracting Piezometer_ID from source.name to easen the evaluation in R
# Columns like Connection_on and connection_off, Host_connected have been removed after quality control.
# After quality control assessement columns of metadata have been removed.
# All Piezometers are merged together in one Excel File and are now ready to analyze them in RStudio.

# Further steps documented in the R Script below.
#======================================================================


# ========== BIBLIOTHEKEN LADEN ==========
library(dplyr)      # Für Datenmanipulation
library(tidyr)      # Für Datenstruktur
library(lubridate)  # Für Datumsoperationen
library(readxl)     # Für Excel-Import

# ========== CONFIGURATION ==========
input_file <- "D:/RProjekte/Hydrologie_Quelccaya/Datenquellen/Hydrological_data/piezometer_data/PZ_merged/PZ_merged/All_PZ_merged.xlsx"
sheet_name <- "Rinput"
date_column <- "Date"        # Column name for timestamp
id_column <- "PZ_ID"         # Column for identification
# ===================================

# ========== STEP 1: LOAD DATA ==========
cat("\n=== STEP 1: Load data ===\n")

# Import Excel file
data_raw <- read_excel(input_file, sheet = sheet_name)

# Initial inspection
cat("Dimensions:", nrow(data_raw), "rows x", ncol(data_raw), "columns\n")
cat("Column names:", paste(names(data_raw), collapse = ", "), "\n")
cat("\nFirst 3 rows:\n")
print(head(data_raw, 3))




























# Lade benötigtes Paket
library(sf)

# Beispiel-Daten (du kannst hier deine eigenen Werte einfügen)
# Spaltennamen müssen "Este" (Easting) und "Norte" (Northing) heißen
puntos <- data.frame(
  Codigo = c("PZ01", "PZ02", "PZ03", "PZ04", "PZ05", "PZ06", "PZ07", "PZ08", "PZ09", "PZ10", "PZ11", "PZ12"),
  Este = c(299053, 299173, 299245, 299328, 299480, 299611, 299604, 299479, 299434, 299306, 299284, 299186),
  Norte = c(8463389, 8463374, 8463449, 8463368, 8463311, 8463320, 8463205, 8463143, 8463200, 8463292, 8463170, 8463245)
)

# Schritt 1: Erstelle ein sf-Objekt mit Koordinaten und UTM-Zone 19S
# EPSG:32719 = WGS84 / UTM zone 19S (Südhalbkugel)
puntos_sf <- st_as_sf(puntos, coords = c("Este", "Norte"), crs = 32719)

# Schritt 2: Transformation in geografische Koordinaten (Dezimalgrad)
puntos_geo <- st_transform(puntos_sf, crs = 4326)

# Schritt 3: Extrahiere Längen- und Breitengrade
puntos_final <- cbind(
  puntos,
  st_coordinates(puntos_geo)
)

# Optional: Spalten umbenennen für Klarheit
names(puntos_final)[names(puntos_final) %in% c("X", "Y")] <- c("Lon_deg", "Lat_deg")

# Ausgabe anzeigen
print(puntos_final)

# Optional: als CSV speichern
# write.csv(puntos_final, "Koordinaten_Quelccaya_WGS84.csv", row.names = FALSE)
