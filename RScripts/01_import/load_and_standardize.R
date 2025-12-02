#======================================================================
# Scriptname: load_and_standardize.R
# Goal(s): 
  # Change Date format to POSIXct
  # Preperation of Analysis of temporal consistency for each dataset the in depth- analysis will be taken place in the respective QC_ scripts.
# Author: Kai Albert Zwießler
# Date: 2025.11.14
# Input Dataset: 
# Outputs: 
  # 




# ========== Load Library ==========
library(dplyr)      # Für Datenmanipulation
library(tidyr)      # Für Datenstruktur
library(lubridate)  # Für Datumsoperationen
library(readxl)     # Für Excel-Import
library(stringr)    # Added to extract Piezometer ID part of tidyr


# Import Data Sources
# Met Station Qori_Kalis "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\STATION_QORIKALIS\\Meteorological_data\\processed\\QORIKALIS_merged.xlsx"
# Piezometer "D:/RProjekte/Hydrologie_Quelccaya/Datenquellen/Hydrological_data/piezometer_data/PZ_merged/PZ_merged/All_PZ_merged.xlsx"

# ========== CONFIGURATION ==========
#Dataframe
input_file <- "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\STATION_QORIKALIS\\Meteorological_data\\processed\\QORIKALIS_merged.xlsx"
#alternative paths: 
# WLS: D:/RProjekte/Hydrologie_Quelccaya/Datenquellen/Hydrological_data/waterlevel_data/WLS_merged.xlsx
#Parameters
sheet_name <- "Rinput"
date_column <- "Date"        # Column name for timestamp
id_column <- "ID"         # Column for identification
output_column <- "time_diff" # Column for calculated output
timediff_column <- "time_diff" # Column for further analysis in the field of temporal consistency 
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

# Convert different date formats like US/EU (..) to ISO 8601 YYYY.MM.DD hh:mm:ss
data_raw <- data_raw %>%
  mutate(
    Date = parse_date_time(
      x = !!sym(date_column),
      orders = c(
        "ymd HMS", "dmy HMS", "mdy HMS", 
        "mdy HMS p", "ymd HM", "dmy HM"
      ),
      tz = "Etc/GMT+5"
    )
  )

# ========== Validation after transformation ==========
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
  message("✓ Date conversion successful. All dates parsed correctly. The Date column contains no NA values")
}
  
# Assigning other columns in their separate scripts
message("Inbetween verification === Are all columns assigned the correct type?===")
print(str(data_raw))

# ========== STEP 3: ORGANIZE DATE column ==========
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

