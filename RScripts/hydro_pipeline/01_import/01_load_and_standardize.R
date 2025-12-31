#======================================================================
# Scriptname: 01_load_and_standardize.R
# Goal(s): 
# Change Date format to POSIXct
# Preperation of Analysis of temporal consistency for each dataset the in depth- analysis will be taken place in the respective QC_ scripts.
# Author: Kai Albert Zwießler
# Date: 2025.11.14
# Input Dataset: 
# Output: 
# standardized data frame: data_standardized

# =======================================
message("Column names have been assigned beforehand in Power Quiery===")
# ========== STEP 1: LOAD DATA ==========
cat("\n=== STEP 1: Load data ===\n")

# Import Excel file
data_raw <- read_excel(INPUT_PIEZOMETER, sheet = SHEET_NAME, guess_max = 100000) # guess_max allows for column identification to character in the maintenance columns.

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

# ========== STEP 4: RENAME OUTPUT VARIABLE ==========
# Rename indicates that this is the standardized output
data_standardized <- data_raw
# Cleanup intermediate variables
rm(data_raw)
cat("\n✓ Step 1 complete: data_standardized ready (", nrow(data_standardized), "rows)\n")

# ==============================================================================
# END OF STEP 1
# Output: data_standardized
# ==============================================================================
