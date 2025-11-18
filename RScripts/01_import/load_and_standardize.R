#======================================================================
# Scriptname: load_and_standardize.R
# Goal(s): 
  # Documentation of steps taken in Power Quiery
  # Change Date format to POSIXct
  # Analysis of temporal consistency
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
library(stringr)    # Added to extract Piezometer ID part of tidyr

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

# ========== STEP 2: STANDARDIZE DATE FORMAT ==========
cat("\n=== STEP 2: Standardize date format to ISO ===\n")

# Show current format
cat("Original date format (first entry):", data_raw[[date_column]][1], "\n")
cat("Original date class:", class(data_raw[[date_column]]), "\n")

# Convert US format (MM.DD.YY hh:mm:ss AM/PM) to ISO
data_raw <- data_raw %>%
  mutate(Date = mdy_hms(Date, tz = "UTC"))

# GOOD PRACTICE: Validate immediately after transformation
cat("Checking date conversion...\n")
sum(is.na(data_raw$Date))


# Assigning multiple columns from logi -> chr format
data_raw <- data_raw %>%
  mutate(across(c(Connection_off, Connection_on, Host_connected, Data_end), 
                as.character))
cat("✓ Converted connection status columns to character format\n")

# ========== STEP 3: Determine time INTERVALS ==========
cat("\n=== STEP 3: Detect time intervals ===\n")

# Calculate time differences for each piezometer !! directly interprets id_column as PZ_ID. sym() converts to a symbol instead of a column like expected. Sort by PZ_ID and then Date.
interval_check <- data_raw %>%
  arrange(!!sym(id_column), Date) %>%  # !! directly interprets id_column as PZ_ID. sym() converts to a symbol instead of a column like expected. Sort by PZ_ID and then Date.
  group_by(!!sym(id_column)) %>% # grouping the piezometer or water level sesors (WLS) according to their ID to different blocks. this functions makes sure only the data of the same devices gets compared and then jumps to the next group for analysis.
  mutate(time_diff = as.numeric(difftime(Date, lag(Date), units = "mins"))) %>%
  ungroup()


# ========== STEP 3: DETECT TIME INTERVALS TO INDENTIFY TIME STEP DEVIATIONS ========== #Note that the mutate command is specificly for PZ_ID´s!!
cat("\n=== STEP 3: Detect time intervals ===\n")

# Extract main ID (PZ01_01 → PZ01_ or WLS_L, WLS_O)
cat("Extracting main IDs...\n")
interval_check <- data_raw %>%
  arrange(!!sym(id_column), Date) %>% # !! directly interprets id_column as PZ_ID. sym() converts to a symbol instead of a column like expected. Sort by PZ_ID and then Date.
  mutate(ID_main = str_sub(!!sym(id_column), 1, 5)) %>%  # Extract first 5 characters and create an new column ID_main.
  cat("/n=== hard coded section with 5 characters, possibly needs to be changed.")

  



