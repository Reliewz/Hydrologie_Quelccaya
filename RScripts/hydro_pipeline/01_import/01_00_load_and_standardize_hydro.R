#======================================================================
# Script name: 01_00_load_and_standardize_hydro.R
# Goal(s): 
  # Folder import of hydrological sensor data and change Date format to POSIXct with load_hobo_csv
  # unite all hydrological sensors in one data frame
  # rename columns
  # Add ID columns and Source.Code
  # drop unwanted columns
  # harmonize missing (NA) codes
  # Convert column types
  # Rename data frame
# Author: Kai Albert Zwießler
# Date: 2025.11.14
# Input Data set: 
# Output: 
  # standardized data frame: data_hydro_standardized


# ========== LOAD DATA ==========
cat("\n=== Load data ===\n")
# .csv folder import WLS outlet, WLS lagoon, Piezometers 1 - 12  ID column generation, rename_column function
# ========== Import function ==========
data_hydro <- purrr::map_dfr(
  names(HYDRO_SENSOR_IMPORTS), \(sensor_id) {  # using sensor_id as a placeholder 
    # cfg ist jetzt z.B.: list(folder="D:\\...", keep_files=NULL, id="PZ01")
    cfg <- HYDRO_SENSOR_IMPORTS[[sensor_id]] # cfg is renamed for every processing step and deleted afterwards
    
    # Import with sensor specific parameters from hydro_config.
    df <- load_hobo_csv(
      folder_path = cfg$FOLDER,      # cfg$folder = folder element from the list
      date_col    = HYDRO_IMPORT_FRAMEWORK$DATE_COLUMN,     # directly taken from config counts for all sensors
      timezone    = TIMEZONE_DATA,   # directly taken from config counts for all sensors
      keep_files  = cfg$KEEP_FILES   # Vectors for WLS all data for PZ
    )
    # Removing device-id from columns for input standardization (required for map_dfr)
    names(df) <- gsub("\\.\\.LGR.*", "", names(df))
    # Add ID column using the ID defined in the configuration
    df %>%
      rename_columns(rename_map = HYDRO_COLUMN_RENAME_MAP) %>% # rename columns according to rename_map, defined in the configuration file
      mutate(ID = cfg$ID)
  }
)

# drop columns
data_hydro <- drop_columns(
  df = data_hydro,
  column_selection = HYDRO_IMPORT_FRAMEWORK$DROP_COLUMNS_FINAL)

# NA code harmonization
data_hydro <- harmonize_NA_codes(
  df = data_hydro,
  measurement_columns = HYDRO_MASTER_DF_FRAMEWORK$MEASUREMENT_COLUMNS,
  NA_codes = HYDRO_MISSING_CODES
)
# documentation
qc_logs[[length(qc_logs)+1]] <- log_qc_decision(
  process_step = "HYDRO Missing code harmonization",
  action = "manual_documentation",
  operator = "Kai Zwießler",
  device = "Hydrological sensors",
  reason = paste(
    "Textual and numeric missing value codes",
    "(S/D, -888.88, -888.9) were converted to NA",
    "prior to quality control procedures.",
    "With a total number of 596 conversions"
  )
)

# Column type harmonization
data_hydro <- convert_column_types(
  df = data_hydro,
  column_definition = HYDRO_COLUMN_ORDER_TYPES,
  timezone = TIMEZONE_DATA
)

# Missing_codes NA_codes harmonization
# RESULT: No differentiationin missing codes

# Rename raw input data to data_hydro_standardized
data_hydro_standardized <- data_hydro


cat("\n✓ Step 1.0 complete: data_hydro_standardized ready (", nrow(data_hydro_standardized), "rows)\n")
# ==============================================================================
# END OF 01_00_load_and_standardize_hydro
# ==============================================================================