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

# ========== STEP 5: IDENTIFY NA SEQUENCES WITH "Protokolliert" ==========
cat("\n=== STEP 4c: Identify maintenance-related NA sequences ===\n")

# ========== IDENTIFY RECORD BLOCKS AROUND "Protokolliert" ==========
cat("\n=== Identify RECORD blocks containing 'Protokolliert' ===\n")

# ---- NEW: Extract sensor group (PZ01, PZ02, …) ----
rows_with_na <- rows_with_na %>%
  mutate(sensor_group = sub("(_.*)$", "", ID)) # New column "sensor_group" Extract everything from the ID until the "_" PZ01_01 -> PZ01

# Find all "Protokolliert" rows
protokolliert_anchors <- rows_with_na %>%
  filter(!is.na(Connection_off) & Connection_off == "Protokolliert") %>% # Filter everything that is not "NA" and that is exatcly "==" "Protokolliert".
  select(sensor_group, ID, RECORD, row_id) %>% # Extract following column names.
  rename(protokolliert_record = RECORD, # rename columns
         protokolliert_row = row_id) 

cat("Found", nrow(protokolliert_anchors), "Protokolliert events\n")
print(protokolliert_anchors)

# Create NA block container
na_with_blocks <- rows_with_na %>% # Pipeline Operator
  arrange(sensor_group, ID, RECORD) %>% # Organize the data first by Sensor_group, then ID and then RECORD.
  mutate(block_id = NA_integer_) # create a new column type "integer" fill in NA for now.

# Build ±1 RECORD blocks within each sensor_group
for(i in 1:nrow(protokolliert_anchors)) { # for indicates the beginning of a loop for the number 1 until the number of Protokolliert anchors.
  
  # safing the sensor group, id and record.
  anchor_group  <- protokolliert_anchors$sensor_group[i]
  anchor_id     <- protokolliert_anchors$ID[i]
  anchor_record <- protokolliert_anchors$protokolliert_record[i]
  
  cat("\nProcessing Protokolliert at GROUP:", anchor_group,
      "ID:", anchor_id, "RECORD:", anchor_record, "\n")
  
  # Building id_rows dataframe so that the loop recieves filtered and arranged data. from one Device at a time.
  id_rows <- na_with_blocks %>% 
    filter(sensor_group == anchor_group, # thats where the changed happen. now we also filter according to sensor group so that now other sensor will get included. Filter only rows where both conditions are true. Sensor Group and anchor_group.
           ID == anchor_id) %>% # filter only rows where the anchor_id matches the ID.
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
    mutate(block_id = ifelse(sensor_group == anchor_group & #ifelse condition. TRUE Argument: only when anchor_group is in the same sensor_group
                               ID == anchor_id & # AND only if the ID matches the Anchor
                               RECORD %in% block_records, # AND the record value is within our generated block.
                             i, block_id)) # If all requirements are met, assign block number of the current loop to index i. FALSE Condition: if not, keep existing block_id
}

# Assign grouped orphan blocks. Blocks that do not have a protokolliert anchor count as orphan blocks.
max_block_id <- max(na_with_blocks$block_id, na.rm = TRUE) # return the maximum value on how many block_id´s exist. ignores NA values.

na_with_blocks <- na_with_blocks %>%
  group_by(sensor_group, ID) %>% # group first by sensor_group then by ID
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

# Summaries
block_summary <- na_with_blocks %>%
  group_by(sensor_group, ID, final_block_id) %>%
  summarise(
    n_rows = n(),
    first_record = min(RECORD),
    last_record = max(RECORD),
    has_protokolliert = any(Connection_off == "Protokolliert", na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(action = ifelse(has_protokolliert, "DELETE", "REVIEW"))

print(block_summary, n = Inf)

#=============STEP 6: Creating a dataframe that contains the selected flags from the previous workflow ===============
cat("Creaiting a dataframe that contains the actions that later will be executed as flags")

# Create full copy of the raw dataset
data_raw_flagged <- data_raw

# Select only the relevant block information
block_info <- na_with_blocks %>%
  select(ID, sensor_group, final_block_id, RECORD)

# Add block information back to the full dataset
#    (This step restores final_block_id for the entire data_raw)
data_raw_flagged <- data_raw_flagged %>%
  left_join(block_info,
            by = c("ID", "RECORD"))

# Join the block actions (REMOVE / REVIEW)
data_raw_flagged <- data_raw_flagged %>%
  left_join(
    block_summary %>% select(ID, sensor_group, final_block_id, action),
    by = c("ID", "sensor_group", "final_block_id")
  ) %>%
  rename(Flags = action)

# ======================STEP 7: Further Explore the temporal context of orphan blocks (Blocks that are not associated with a "protokolliert" anchor.)==============================

# select orphan blocks
orphans_clean <- na_with_blocks %>% 
  filter(final_block_id == 44) %>%
  select(ID, Date, RECORD, Abs_pres, Temp) %>%
  arrange(ID, Date)

print(orphans_clean, n = Inf, width = Inf)


