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
# All Piezometers are merged in Excel to further analyse them in RStudio
#======================================================================

#Sources required
source("RScripts/01_import/load_and_standardize.R")
source("RScripts/utils/qc_functions/function_time.R")
source("RScripts/utils/qc_functions/function_coordinate_transformation.R")

# ========== CONFIGURATION ==========
# Parameters
sheet_name <- "Rinput"
date_column <- "Date"        # Column name for Date
id_column <- "ID"         # Column for identification
output_column <- "time_diff" # Column for calculated output
# Coordinate data: Piezometer + BAROM
utm_coords_pz <- data.frame(Device = c(paste0("PZ", sprintf("%02d", 1:12)), "BAROM"),
                            x = c(299184.3993, 299279.3782, 299475.9968, 299601.0980, 299607.1613, 
                                  299479.9303, 299432.1672, 299302.1533, 299168.8984, 299240.7638, 
                                  299053.4642, 299322.6926, 298822.5337),
                            y = c(8463245.9423, 8463168.2165, 8463142.1306, 8463205.7897, 8463323.1859, 
                                  8463313.4492, 8463202.6988, 8463294.1563, 8463376.2507, 8463452.2814, 
                                  8463383.1424, 8463376.6515, 8463357.8907))
# ===================================

# ======STEP 1 =======
cat("Step 1: Columns and data type")
# Assigning multiple columns from logi -> chr format
data_raw <- data_raw %>%
  mutate(across(c(Connection_off, Connection_on, Host_connected, Data_end), 
                as.character))
cat("✓ Converted connection status columns to character format")
message("columns have been assigned the correct type.")

#===== STEP 2: Verify no missing values were found by the previous workflow
cat("Step 2: No missing values found in Date column. Continuing with Analysis...")

#===== STEP 3: Coordinate transformation from UTM Zone 19s to WGS84
cat("Step 3: Coordinate transformation. UTM Zone 19S to WGS84")
wgs_coords_pz <- utm_to_latlon(
  df = utm_coords_pz,
  x_col = "x",
  y_col = "y",
  zone = 19,
  hemisphere = "south"
)

#===== STEP 4 Starting with the temporal evaluation if timesteps are uniform and tiding steps are necessary.
cat("Starting with the temporal evaluation if timesteps are uniform and tiding steps are necessary.")

# calculating the time different between the timesteps for temporal consistency test. creating time_diff column, using function_time.R
interval_check <- calc_time_diff(
  df = data_raw,
  id_col = id_column,
  date_col = date_column,
  out_col = output_column
)


# ========== 4a Analyze intervals per piezometer group ==========
cat("\nStep4a: Analyzing time intervals per piezometer...\n")

interval_summary <- interval_check %>%
  filter(!is.na(time_diff)) %>%  # Filter/Remove NA values (first entry per piezometer)
  group_by(ID) %>%
  summarise(
    n_measurements = n(),
    min_interval = min(time_diff),
    max_interval = max(time_diff),
    average_interval = mean(time_diff),
    n_15min = sum(time_diff == 15), # Count specific intervals:
    n_60min = sum(time_diff == 60),
    n_between = sum(time_diff > 15 & time_diff < 60),
    n_above_60 = sum(time_diff > 60),   # gaps!
    n_below_15 = sum(time_diff < 15),  # Unexpected values potentially in connection with maintanance and sensor errors
    .groups = "drop" # same effect than the command ungroup(), special for summarize.
  )

# Display results
cat("\n=== Interval Summary by Piezometer ===\n")
print(interval_summary, n = Inf)

# ========== STEP 4b: Identify columns that have no information content ==========
cat("\n=== STEP 4b: Prepairing to remove columns without any information content ===\n")

# Identify rows with NA in on of the two measurement columns and safe it for further examination in the dataframe rows_with_na
rows_with_na <- data_raw %>%
  mutate(
    row_id = row_number(), # extracts the original row number from the dataset. Because filter() function would assign new ones.
    has_any_na = is.na(Abs_pres) | is.na(Temp) # if one of the two is NA it gets stored in the object has_any_na
  ) %>%
  filter(has_any_na == TRUE) # Since the output of is.na() function is logical (TRUE/FALSE) == makes sure that only outputs with TRUE get filtered.

# Summary
cat("Total rows with NA:", nrow(rows_with_na), "\n")
cat("  - Abs_pres NA:", sum(is.na(rows_with_na$Abs_pres)), "\n")
cat("  - Temp NA:    ", sum(is.na(rows_with_na$Temp)), "\n")

# Display all rows with NA
cat("\n=== All rows with missing values ===\n")
print(rows_with_na, n = 40)

# ========== STEP 5: IDENTIFY NA SEQUENCES WITH "Protokolliert" they are maintance related. ==========
cat("\n=== STEP 4c: Identify maintenance-related NA sequences ===\n")

# ========== IDENTIFY RECORD BLOCKS AROUND "Protokolliert" ==========
cat("\n=== Identify RECORD blocks containing 'Protokolliert' ===\n")

# Step 1: Find all "Protokolliert" rows
protokolliert_anchors <- rows_with_na %>%
  filter(!is.na(Connection_off) & Connection_off == "Protokolliert") %>% #filter all rows where exactly "protokolliert" appears in the "connection_off" column
  select(ID, RECORD, row_id) %>% # extract only this 3 columns
  rename(protokolliert_record = RECORD, protokolliert_row = row_id) # rename the columns to clarify the "protokolliert" connection

cat("Found", nrow(protokolliert_anchors), "Protokolliert events\n")
print(protokolliert_anchors)

# Step 2: For each NA row, find if it belongs to a "Protokolliert" block
na_with_blocks <- rows_with_na %>% # Send all NA rows into the pipeline operator
  arrange(ID, RECORD) %>% # organize primary ID secondary RECORD
  mutate(block_id = NA_integer_) # generate a new column that will later get filled.

# Step 3: For each Protokolliert anchor, expand in both directions
for(i in 1:nrow(protokolliert_anchors)) { # loop to build a block for each "protokolliert" event. starting at 1, ":" is an operator who sets the range on how many protokolliert anchors exist and how many times the loop hast to continue.
  anchor_id <- protokolliert_anchors$ID[i] # safing the protokolliert_ID according to the timestep [i]
  anchor_record <- protokolliert_anchors$protokolliert_record[i] # safing the protokolliert_record according to the timestep [i].
  #This logic ensures that the "protokolliert ID and RECORD serves as an anchor where future operations will build on.
  
  cat("\nProcessing Protokolliert at ID:", anchor_id, "RECORD:", anchor_record, "\n")
  
  # Get all rows for this ID
  id_rows <- na_with_blocks %>%
    filter(ID == anchor_id) %>%
    arrange(RECORD)
  
  # Find the anchor position
  anchor_pos <- which(id_rows$RECORD == anchor_record)
  
  if(length(anchor_pos) == 0) next
  
  # Expand backward (lower RECORD numbers)
  block_records <- anchor_record
  current_pos <- anchor_pos - 1
  
  while(current_pos >= 1) {
    current_record <- id_rows$RECORD[current_pos]
    diff <- anchor_record - current_record
    
    # Check if connected (within ±2 of any block member)
    if(any(abs(block_records - current_record) <= 2)) {
      block_records <- c(block_records, current_record)
      current_pos <- current_pos - 1
    } else {
      break  # Not connected, stop
    }
  }
  
  # Expand forward (higher RECORD numbers)
  current_pos <- anchor_pos + 1
  
  while(current_pos <= nrow(id_rows)) {
    current_record <- id_rows$RECORD[current_pos]
    
    # Check if connected (within ±2 of any block member)
    if(any(abs(block_records - current_record) <= 2)) {
      block_records <- c(block_records, current_record)
      current_pos <- current_pos + 1
    } else {
      break  # Not connected, stop
    }
  }
  
  # Mark all these records with block ID
  na_with_blocks <- na_with_blocks %>%
    mutate(
      block_id = ifelse(ID == anchor_id & RECORD %in% block_records, i, block_id)
    )
  
  cat("  Block", i, "contains", length(block_records), "records:",
      paste(sort(block_records), collapse=", "), "\n")
}

# Step 4: Assign remaining NA rows (without Protokolliert) to separate blocks
max_block_id <- max(na_with_blocks$block_id, na.rm = TRUE)

na_with_blocks <- na_with_blocks %>%
  group_by(ID) %>%
  arrange(RECORD) %>%
  mutate(
    # For rows without block_id, create new blocks
    is_orphan = is.na(block_id),
    record_diff_prev = RECORD - lag(RECORD),
    new_orphan_block = is_orphan & (row_number() == 1 | is.na(record_diff_prev) | record_diff_prev > 2),
    orphan_block_id = ifelse(is_orphan, cumsum(new_orphan_block) + max_block_id, NA)
  ) %>%
  mutate(
    final_block_id = ifelse(is.na(block_id), orphan_block_id, block_id)
  ) %>%
  ungroup()

cat("\n=== First 30 rows with block assignment ===\n")
print(na_with_blocks %>%
        select(row_id, ID, RECORD, Connection_off, final_block_id) %>%
        head(30))

# Step 5: Summarize blocks
block_summary <- na_with_blocks %>%
  group_by(ID, final_block_id) %>%
  summarise(
    n_rows = n(),
    first_record = min(RECORD),
    last_record = max(RECORD),
    has_protokolliert = any(!is.na(Connection_off) & Connection_off == "Protokolliert"),
    .groups = "drop"
  ) %>%
  mutate(
    action = ifelse(has_protokolliert, "REMOVE", "KEEP")
  )

cat("\n=== Block Summary ===\n")
print(block_summary, n = Inf)

cat("\n=== Statistics ===\n")
cat("Total blocks:", nrow(block_summary), "\n")
cat("  WITH Protokolliert (REMOVE):", sum(block_summary$has_protokolliert), "\n")
cat("  WITHOUT Protokolliert (KEEP):", sum(!block_summary$has_protokolliert), "\n")


