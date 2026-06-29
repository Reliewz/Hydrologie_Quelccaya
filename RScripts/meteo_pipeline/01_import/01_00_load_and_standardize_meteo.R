#======================================================================
# Script name: 01_00_load_and_standardize_meteo.R
# Goal(s): 
  # Execution of import function for meteorological station Qori-Kalis with load_qk_csv
  # create a data list of all meteorological stations and unite all meteorological stations into one data frame named: data_meteo
  # Missing code harmonization
  # Documentation of missing code step including the number of missing codes converted
  # Column type harmonization
  # rename data frame
# Author: Kai Albert Zwießler
# Date: 2025.11.14
# Input Dataset:
  # Meteorological stations QUELCCAYA & SENAMHI sourced with the master script
  # Meteorological station Qori-Kalis
# Output: 
  # standardized data frame: data_meteo_standardized

# ========== LOAD DATA ==========
cat("\n=== Load data ===\n")

# Load Qori-Kalis data frame
data_qk <- load_qk_csv(METEO_SENSOR_IMPORTS$STATION_QK,
                       timezone = TIMEZONE_DATA
                       )

# Generate data_meteo with all meteorological station data
data_list <- list(
  data_qk        = data_qk,
  data_qq        = data_qq,
  data_qp = data_qp_joined,
  data_sc = data_sc_joined,
  data_cb = data_cb_joined
)

# Generate a tibble with all meteorological data
data_meteo <- bind_rows(data_list)

# NA_code harmonization (missing values codes)
data_meteo <- harmonize_NA_codes(
  df = data_meteo,
  measurement_columns = METEO_MEASUREMENT_COLUMNS,
  NA_codes = METEO_MISSING_CODES
)

# documentation date 26.06.2026
qc_logs[[length(qc_logs)+1]] <- log_qc_decision(
  process_step = "METEO Missing code harmonization",
  action = "manual_documentation",
  operator = "Kai Zwießler",
  device = "Meteorological stations",
  reason = paste(
    "Textual and numeric missing value codes",
    "(S/D, -888.88, -888.9) were converted to NA",
    "prior to quality control procedures.",
    "With a total number of 38888 conversions"
  )
)

# Column type harmonization
data_meteo <- convert_column_types(
  df = data_meteo,
  column_definition = METEO_COLUMN_ORDER_TYPES,
  timezone = TIMEZONE_DATA
)



# ========== RENAME OUTPUT VARIABLE ==========
data_meteo_standardized <- data_meteo


cat("\n✓ Step 1 complete: data_meteo_standardized ready (", nrow(data_standardized), "rows)\n")
# ==============================================================================
# END OF 01_00_load_and_standardize_meteo
# ==============================================================================
