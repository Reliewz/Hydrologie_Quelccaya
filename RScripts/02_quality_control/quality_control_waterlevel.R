#======================================================================
# Scriptname: quality_control_waterlevel.R
# Goal(s): 
  # Documentation steps in Power Quiery
# Author: Kai Albert Zwießler
# Date: 2025.11.12
# Input Dataset: data/WLS_merged.xlsx
# Outputs: 
  # 
# Units:
  # Abs.pres <- kPa
  # Temp <- °C
# Sensor information:
  # Datalogger lagoon S/N: 21826493
  # Sensor lagoon WLS_L S/N: 21826493
  # Datalogger Outlet S/N: 21826515
  # Sensor Outlet WLS_O S/N: 21826515

#======================================================================
##Documentation of Power Quiery steps##
# First column removed
# Correct column assigned as headlines
# Changed all column names from to general standart amogs datasets
# Changing order of columns
# Data in Folder merged
# Assigned a Source.Name to every line
# Assigned a ID column to identify individual sensor
# All water level data is now merged into one Excel file for furhter analysis in RStudio.
#======================================================================

#Sources required
source("RScripts/01_import/load_and_standardize.R")
source("RScripts/utils/qc_functions/function_time.R")
source("RScripts/utils/qc_functions/function_timediff_sum.R")
source("RScripts/utils/qc_functions/function_coordinate_transformation.R")

# ========== CONFIGURATION ==========
# Parameters
#Process Parameters
date_column <- "Date"        # Column name for timestamp
id_column <- "ID"         # Column for identification
output_column <- "time_diff" # Column for calculated output
timediff_column <- "time_diff" # Column for further analysis in the field of temporal consistency 
measurement_columns <- c("Abs_pres", "Temp")
maintenance_info_columns <- c("Connection_off", "Connection_on", "Host_connected", "Data_end")

# Metadata parameters
sensor_units <- list(Abs_pres = "kPa", Temp = "°C")
Sensor_information <- list(
  WLS_L_SN = "21826493",
  WLS_O_SN = "21826515")

#Workflow Parameter
record_tolerance <- 1
timezone <- "America/Lima GMT +5"

# Coordinate data: WLS + BAROM
utm_coords_wls <- data.frame(Device = c("WLS_L", "WLS_O", "BAROM"),
                             x = c(300467.4405, 297097.5124, 298822.5337),
                             y = c(8462061.4462, 8463168.4825, 8463357.8907))
# ===================================

cat("Step 1: Columns and data type")
# Assigning multiple columns from logi -> chr format
data_raw <- data_raw %>%
  mutate(across(all_of(maintenance_info_columns), # all_of for vectors, instead of !!sym() for strings/symbols
                as.character))
cat("✓ Converted connection status columns to character format")
message("columns have been assigned the correct type.")

cat("Step 2: No missing values in Date column found. Continuing with Analysis")

# calculating the time different between the timesteps for temporal consistency test. creating time_diff column, using function_time.R
interval_check <- calc_time_diff(
  df = data_raw,
  id_col = id_column,
  date_col = date_column,
  out_col = output_column
)

# Step 3 coordinate transformation + Barometer coordinates
wgs_coords_wls <- utm_to_latlon(
  df = utm_coords_wls,
  x_col = "x",
  y_col = "y",
  zone = 19,
  hemisphere = "south"
)

# ========== 4b Analyze intervals per WLS group ==========
cat("\nStep4b: Analyzing time intervals per WLS...\n")
# ========== 4a Analyze intervals and generate statistical summary with function_timediff_sum.R ==========
cat("\nStep4a: Analyzing time temporal consistency intervals per piezometer...\n")
interval_summary <- sum_timediff(
  df = interval_check,
  id_col = id_column,
  date_col = date_column,
  td_col = output_column
)

# Display results
cat("\n=== Interval Summary by Water Level Sensors ===\n")
print(interval_summary, n = Inf)

# ========== STEP 4b: Identify columns that have no information content ==========
cat("\n=== STEP 4b: Prepairing to remove columns without any information content ===\n")

# Identify rows with NA in on of the two measurement columns and safe it for further examination in the dataframe rows_with_na
rows_with_na <- data_raw %>%
  mutate(
    row_id = row_number(), # extracts the original row number from the dataset. Because filter() function would assign new ones.
    has_any_na = if_any(all_of(measurement_columns), is.na)) %>% # if one of the two is NA it gets stored in the object has_any_na
  filter(has_any_na == TRUE) # Since the output of is.na() function is logical (TRUE/FALSE) == makes sure that only outputs with TRUE get filtered.

# Summary
rows_with_na %>%
  summarise(across(all_of(measurement_columns), ~ sum(is.na(.x))))

# Display all rows with NA
cat("\n=== All rows with missing values ===\n")
print(rows_with_na, n = 40)

# ========== STEP 5: IDENTIFY NA SEQUENCES WITH "Protokolliert" ==========
cat("\n=== STEP 4c: Identify maintenance-related NA sequences ===\n")

# ========== IDENTIFY RECORD BLOCKS AROUND "Protokolliert" ==========
cat("\n=== Identify RECORD blocks containing 'Protokolliert' ===\n")

# Find all "Protokolliert" rows
protokolliert_anchors <- rows_with_na %>%
  filter(
    !is.na(.data[[maintenance_info_columns[1]]]) & #.data[[]] allows to access a column via a string.
      .data[[maintenance_info_columns[1]]] == "Protokolliert" # Filter everything that is not "NA" and that is exactly "Protokolliert".
  ) %>%
  select(sensor_group, ID, RECORD, row_id) %>% # Extract following column names.
  rename(
    protokolliert_record = RECORD,
    protokolliert_row = row_id # rename columns
  )

cat("Found", nrow(protokolliert_anchors), "Protokolliert events\n")
print(protokolliert_anchors)

# Step 2: Create NA block container
na_with_blocks <- rows_with_na %>% # Pipeline Operator
  arrange(ID, RECORD) %>% # Organize the data first by then ID and then RECORD.
  mutate(block_id = NA_integer_) # create a new column type "integer" fill in NA for now.

# Step 3: Build ±1 RECORD blocks within each ID
for(i in 1:nrow(protokolliert_anchors)) { # for indicates the beginning of a loop for the number 1 until the number of Protokolliert anchors.
  
  # safing the sensor group, id and record.
  anchor_id     <- protokolliert_anchors$ID[i]
  anchor_record <- protokolliert_anchors$protokolliert_record[i]
  
  cat("\nProcessing Protokolliert at GROUP:", anchor_group,
      "ID:", anchor_id, "RECORD:", anchor_record, "\n")
  
  # Building id_rows dataframe so that the loop recieves filtered and arranged data. from one Device at a time.
  id_rows <- na_with_blocks %>% 
    filter(ID == anchor_id) %>% # filter only rows where the anchor_id matches the ID.
    arrange(RECORD)
  
  # Build dataframe anchor_pos to extract the "protokolliert" rows
  anchor_pos <- which(id_rows$RECORD == anchor_record) # establishes a logic vector where id_rows$reocrds matches anchor_record. Which extracts the row number.
  if(length(anchor_pos) == 0) next # Check if in the filtered rows a anchor "protokolliert" can be detected. if not the next rows will be analyszed
  
  block_records <- anchor_record
  
  # === backward (±1 only) ===
  current_pos <- anchor_pos - 1 # Starting point. Start is a row before the anchor.
  while(current_pos >= 1) { # while loop. The loop continues itself as long as the conditions are TRUE. WHILE - COndition. as long as we have rows the loop continues. Makes sure that it stops when no more rows exist.
    current_record <- id_rows$RECORD[current_pos] # the values of the id_rows$Record is extracted and will be compared later with block_records [] allow to work with the index not value
    if(any(abs(block_records - current_record) <= 1)) { # IF. only if the condition is true the block will be executed. any() allows the if condition to accept more than 1 logical decision, allows the current_pos to get compared to ALL block numbers. Because it originally accepts only 1. abs() checks value independently of its algebraic sign. allowing connections to all block numbers in both directions
      block_records <- c(block_records, current_record) # combine logic that attaches the current_pos to the block records.
      current_pos <- current_pos - 1  
    } else break
  }
  
  # === forward (±1 only) ===
  current_pos <- anchor_pos + 1 # forward count from "protokolliert" anchor_pos.
  while(current_pos <= nrow(id_rows)) { #nrows marks the last record index existing in this dataframe. Tells the loop where to stop.
    current_record <- id_rows$RECORD[current_pos]
    if(any(abs(block_records - current_record) <= 1)) {
      block_records <- c(block_records, current_record)
      current_pos <- current_pos + 1
    } else break
  }
  
  # Write block_id
  na_with_blocks <- na_with_blocks %>%
    mutate(block_id = ifelse(ID == anchor_id & # AND only if the ID matches the Anchor
                             RECORD %in% block_records, # AND the record value is within our generated block.
                             i, block_id)) # If all requirements are met, assign block number of the current loop to index i. FALSE Condition: if not, keep existing block_id
}

# Step 4: Assign grouped orphan blocks. Blocks that do not have a protokolliert anchor count as orphan blocks.
max_block_id <- max(na_with_blocks$block_id, na.rm = TRUE) # return the maximum value on how many block_id´s exist. ignores NA values.

na_with_blocks <- na_with_blocks %>%
  group_by(ID) %>% # group by ID
  arrange(RECORD) %>% # organize the data by records
  mutate(
    is_orphan = is.na(block_id), # counts as orphan when it didnt get assigned to a "protokolliert" block yet and therefore has NA
    record_diff_prev = RECORD - lag(RECORD), # logic to detect jumps when difference higher than 1.
    new_orphan_block = is_orphan &
      (row_number() == 1 | is.na(record_diff_prev) | record_diff_prev > 1), # rows that mark the beginning of a new orphan block 
    orphan_block_id = ifelse(is_orphan,
                             cumsum(new_orphan_block) + max_block_id, # to assign all orphan blocks the number 44
                             NA),
    final_block_id = ifelse(is.na(block_id), orphan_block_id, block_id) # if else condition when block ID contains NA use orphan block id or keep the original block_id
  ) %>%
  ungroup()

# Step 5: Summaries
block_summary <- na_with_blocks %>%
  group_by(ID, final_block_id) %>%
  summarise(
    n_rows = n(),
    first_record = min(RECORD),
    last_record = max(RECORD),
    has_protokolliert = any(Connection_off == "Protokolliert", na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(action = ifelse(has_protokolliert, "DELETE", "REVIEW"))

print(block_summary, n = Inf)

# Creating a dataframe that contains the selected flags
cat("Creaiting a dataframe that contains the actions that later will be executed as flags")

# 1) Create full copy of the raw dataset
data_raw_flagged <- data_raw

# 2) Select only the relevant block information
block_info <- na_with_blocks %>%
  select(ID, final_block_id, RECORD)

# 3) Add block information back to the full dataset
#    (This step restores final_block_id for the entire data_raw)
data_raw_flagged <- data_raw_flagged %>%
  left_join(block_info,
            by = c("ID", "RECORD"))

# 4) Join the block actions (REMOVE / REVIEW)
data_raw_flagged <- data_raw_flagged %>%
  left_join(
    block_summary %>% select(ID, final_block_id, action),
    by = c("ID", "final_block_id")
  ) %>%
  rename(Flags = action)





# select orphan blocks
orphans_clean <- na_with_blocks %>% 
  filter(final_block_id == 44) %>%
  select(ID, Date, RECORD, Abs_pres, Temp) %>%
  arrange(ID, Date)

print(orphans_clean, n = Inf, width = Inf)
