#======================================================================
# Scriptname: load_and_standardize.R
# Goal(s): 
  # Documentation of steps taken in Power Quiery
  # Change Date format to POSIXct
  # Preperation of Analysis of temporal consistency -> Note that the "time_diff" column will be established for each data set but             analyszed is the respective QC_ scripts.
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
# First column removed from every data set with example file
# Correct columns assigned as headlines
# Changed column names to universal terms across all data sets
# Adding customized column to convert the date from US to format: YYYY-MM-DD hh:mm:ss
# = DateTime.FromText([#"Date Time, GMT-5:00"], "en-US")
# = DateTime.ToText([Date_Standardized], "yyyy-MM-dd HH:mm:ss")
# Changing order of column & removing old Date column
# Changing type to decimal with location information "English (USA)"
# Assigning a Source.Name to every line
# Extracting Piezometer_ID and WLS_ID from source.name
# All Piezometers and WLS data are merged together in one Excel File and are now ready to analyze them in RStudio.

# Further steps documented in the R Script below.
#======================================================================


# ========== Load Library ==========
library(dplyr)      # Für Datenmanipulation
library(tidyr)      # Für Datenstruktur
library(lubridate)  # Für Datumsoperationen
library(readxl)     # Für Excel-Import
library(stringr)    # Added to extract Piezometer ID part of tidyr

#Sources



# ========== CONFIGURATION ==========
#Dataframe
input_file <- "D:/RProjekte/Hydrologie_Quelccaya/Datenquellen/Hydrological_data/piezometer_data/PZ_merged/PZ_merged/All_PZ_merged.xlsx"
#Parameters
sheet_name <- "Rinput"
date_column <- "Date"        # Column name for timestamp
id_column <- "ID"         # Column for identification
# ===================================
message("Column names have been assigned beforehand in Power Quiery===")
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
cat("\n=== STEP 2: Standardize date format to ISO 8601 ===\n")

# Show current format
cat("Original date format (first entry):", data_raw[[date_column]][1], "\n")
cat("Original date class:", class(data_raw[[date_column]]), "\n")

# Convert US format (MM.DD.YY hh:mm:ss AM/PM) to ISO 8601
data_raw <- data_raw %>%
  mutate(Date = mdy_hms(!!sym(date_column), tz = "Etc/GMT+5"))

# ========== STEP 3: GPE Validation after transformation ==========
cat("Validate date convertion...")

if (any(is.na(data_raw[[date_column]]))) {
    n_failed_parsing <- sum(is.na(data_raw[[date_column]]))
    n_total <- nrow(data_raw)
    pct_failed <- round((n_failed_parsing / n_total) * 100, 2)
    warning(sprintf(
    "Date conversion failed: column '%s' contains NA values after parsing.",
    date_column
    ))
    # Extract problematic row indices
    failed_rows <- which(is.na(data_raw[[date_column]]))
    
    # ===== PREPARE DATA FOR QC ANALYSIS =====
    
    # Show problematic rows with ALL columns for context
    cat("\n   Problematic rows (first 10 with all columns):\n")
    problem_rows <- data_raw %>%
      filter(is.na(!!sym(date_column))) %>%
      head(10)
    print(problem_rows)
} else {
  # All dates parsed successfully
  cat("✓ Date conversion successful. All dates parsed correctly. The Date column contains no NA values")
}
  
#Assigning other columns in their seperate scripts
message("Inbetween verification === Are all columns assigned the correct type?===")
print(str(data_raw))

cat("\n=== STEP 3: Sort data by ID (if available) and Date ===\n")

if (id_column %in% names(data_raw)) {
  data_raw <- data_raw %>% 
    arrange(!!sym(id_column), !!sym(date_column))
} else {
  warning(sprintf("ID column '%s' not found. Sorting only by date.", id_column))
  data_raw <- data_raw %>% 
    arrange(!!sym(date_column))
}

# Show results
cat("First 3 rows after sorting:\n")
print(head(data_raw, 3))

 

