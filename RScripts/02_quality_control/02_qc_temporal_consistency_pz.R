#======================================================================
# Script name: 02_qc_temporal_consistency_pz.R
# Goal(s): 
  # Temporal consistency among Date column
  # Cleaning of maintenance - related events
# Author: Kai Albert Zwießler
# Date: 2025.11.14
# Input Data set: Hydrological_data/piezometer_data/PZ_merged/PZ_merged/All_PZ_merged.xlsx
# Outputs: 
  # data frame: data_raw_flagged


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

# Sources required
source("RScripts/01_import/master_clean_data_hydro.R")
source("RScripts/01_import/load_and_standardize.R")
source("RScripts/utils/qc_functions/function_time.R")
source("RScripts/utils/qc_functions/function_timediff_sum.R")
source("RScripts/utils/qc_functions/function_interval_determination.R")
source("RScripts/utils/qc_functions/function_coordinate_transformation.R")
source("RScripts/utils/qc_functions/function_apply_qc_flags.R")
source("RScripts/utils/qc_functions/function_log_qc_flags.R")

# ========== CONFIGURATION ==========
# Parameters
# Process Parameters temporal consistency
date_column <- "Date"        # Column name for timestamp
id_column <- "ID"# Column for identification
sensor_group_column <- "sensor_group"
output_column <- "time_diff" # Column for calculated output
timediff_column <- "time_diff" # Column for further analysis in the field of temporal consistency 
measurement_columns <- c("Abs_pres", "Temp")
maintenance_info_columns <- c("Connection_off", "Connection_on", "Host_connected", "Data_end")
  # apply qc flags workflow
apply_flags_column <- "Flags"
merge_column <- "RECORD"

# Metadata parameters
sensor_units <- list(Abs_pres = "kPa", Temp = "°C")
Sensor_information <- list(
  PZ01_SN = "21826509",
  PZ02_SN = "21826502",
  PZ03_SN = "21826497",
  PZ04_SN = "21826519",
  PZ05_SN = "21826512",
  PZ06_SN = "21826504",
  PZ07_SN = "21826505",
  PZ08_SN = "21826596",
  PZ09_SN = "21826594",
  PZ10_SN = "21826516",
  PZ11_SN = "21826500",
  PZ12_SN = "21826503")


# Workflow Parameters:
record_tolerance <- 1
timezone_data <- "America/Lima"
timezone_process <- "Europe/Berlin"


# Outputs
log_file <- "results/logs/qc_log_piezo__temporal_consistency.csv"

# ===================================

# ======STEP 1 =======
cat("Step 1: Columns and data type")
# Assigning multiple columns from logi -> chr format
data_raw <- data_raw %>%
  mutate(across(all_of(maintenance_info_columns), # all_of for vectors, instead of !!sym() for strings/symbols
                as.character))
cat("✓ Converted connection status columns to character format")
message("columns have been assigned the correct type.")
# Assign a sensor group column to the dataframe for further analysis.
data_raw <- data_raw %>%
mutate(sensor_group = sub("(_.*)$", "", ID))

#===== STEP 4 Starting with the temporal evaluation if time steps are uniform and data cleaning steps are necessary.
cat("Starting with the temporal evaluation if timesteps are uniform and data data cleaning steps are necessary.")

# STEP 4a calculating the time different between the time steps for temporal consistency test. creating time_diff column, using function_time.R
interval_check <- calc_time_diff(
  df = data_raw,
  id_col = id_column,
  date_col = date_column,
  out_col = output_column
)

# ========== 4b Analyze intervals and generate statistical summary with function_timediff_sum.R ==========
cat("\nStep4a: Analyzing time temporal consistency intervals per piezometer...\n")
interval_summary <- sum_timediff(
  df = interval_check,
  id_col = id_column,
  date_col = date_column,
  td_col = timediff_column
)
cat("\n=== Interval Summary by Piezometer group ===\n")
print(interval_summary, n = Inf)

# ========= 4c Visual determination of rows with temporal inconsistencies with function_interval_determination.R ========
# categories and thresholds are determined internally in the function-logic.
temporal_issues_rows <- check_temporal_inconsistencies(
  df = interval_check,
  id_col = id_column,
  date_col = date_column,
  timediff_col = timediff_column
)
print(temporal_issues_rows)

# ========== STEP 5: Identify columns that have no information content ==========
cat("\n=== STEP 4b: Preparing to remove columns without any information content (NA) ===\n")

# Identify rows with NA in on of the two measurement columns and safe it for further examination in the data frame rows_with_na
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

# ========== STEP 6: IDENTIFY NA SEQUENCES WITH "Protokolliert" ==========
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

# Create NA block container
na_with_blocks <- rows_with_na %>% # Pipeline Operator
  arrange(sensor_group, !!sym(id_column), !!sym(date_column), RECORD) %>% # Organize the data first by Sensor_group, then ID and then RECORD.
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
    is_orphan = is.na(block_id), # counts as orphan when it didn´t get assigned to a "protokolliert" block yet and therefore has NA
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


#=============STEP 7: Creating a data frame that contains all QC flags determined in the separated workflows ===============
cat("Creating a data frame that contains the actions that contains the flags from the previous workflow")

# Create full copy of the raw data set to create a flagged version
data_raw_flagged <- data_raw

# Preparing the object flag_info to transfer "RECORD" column
flag_info <- na_with_blocks %>%
  select(ID, RECORD, final_block_id)

# Merge information with data_raw_flagged, add block logic
data_raw_flagged <- data_raw_flagged %>%
  left_join(flag_info,
            by = c("ID", "RECORD"))

# Isolation of DELETE-blocks
delete_blocks <- block_summary %>% filter(action == "DELETE")
# Assign "DELETE" flag to the respective rows with function apply_qc_flags
data_raw_flagged <- apply_qc_flags(
  df = data_raw_flagged,
  df_flag_info = delete_blocks,
  flag_value = "DELETE",
  apply_flags_col = apply_flags_column,
  merge_col = "final_block_id",
  id_col = id_column
)

# Isolation of REVIEW-Blocks
review_blocks <- block_summary %>% filter(action == "REVIEW")
# Assign "REVIEW" flag to the respective rows with function apply_qc_flags
data_raw_flagged <- apply_qc_flags(
  df = data_raw_flagged,
  df_flag_info = review_blocks,
  flag_value = "REVIEW",
  apply_flags_col = apply_flags_column,
  merge_col = "final_block_id",
  id_col = id_column
)

# ==== MAINTENANCE RELATED ANALYSIS ====
# PURPOSE: === Cleansing of "DELETE" Flags and re-run the sum_timediff function. ====
# Transfering the flagged records to a experimental data frame where the upcoming analysis of temporal consistency will be carried out
flag_info <- data_raw_flagged %>%
  select(ID, RECORD, Flags)

# STEP 1: Add flag information to experimental data set
interval_check <- interval_check %>% 
  left_join(flag_info,
            by = c("ID", "RECORD"))

# STEP 2: Documentation of flagging workflow
# Isolating DELETED rows to prepare documentation with function_log_qc_flags.
deleted_rows <- interval_check %>% 
  filter(Flags == "DELETE")

# create a tibble to safe documentation developed by log_qc_flags
qc_log_piezometer <- tibble::tibble()

# Documentation of QC Flags using function log_qc_flags
qc_log_piezometer <- bind_rows(qc_log_piezometer <- log_qc_flags(
  df = deleted_rows,
  action = "initial_assignment",
  to_flag = 'DELETE',
  reason = "The isolated segment adds no additional information content to analysis, because of NA values in the measurement columns. Protocolled maintenance or data collection events caused the sensor to lose it´s connection. For further analysis this rows will be excluded."
))


# Keep all rows that are not "DELETE" also keep NA values.
interval_check <- interval_check %>%
  filter(Flags != "DELETE" | is.na(Flags))

# ====STEP 3: Filter all rows marked as "REVIEW" =====
# Documentation "REVIEW" flags since there is no information content in the measurement value section
review_rows <- interval_check %>% 
  filter(Flags == "REVIEW")

# ===== Review Flags documentation =====
# Documentation of QC Flags using function log_qc_flags
qc_log_piezometer <- bind_rows(qc_log_piezometer, log_qc_flags(
  df = review_rows,
  action = "initial_assignment",
  to_flag = 'REVIEW',
  reason = "The isolated segments are flagged as REVIEW, since it not related to directly related to a protocolled disconnection of the sensor. In a second step other maintenance and information columns will be reviewed."
))

# === After REVIEW Flag analysis: Reclassification of REVIEW Flags ===
# Documentation of QC Flags using function log_qc_flags
qc_log_piezometer <- bind_rows(qc_log_piezometer, log_qc_flags(
  df = review_rows,
  action = "reclassification",
  from_flag = 'REVIEW',
  to_flag = 'DELETE',
  reason = "The isolated 'REVIEW' segment also add no additional information content to analysis, because of NA values in the measurement columns. The reason was a protocolled re-booting mechanism, also after maintenance or data collection events. For further analysis this rows can be excluded."
))

# ===Documentation Append to Log file ===
# Load existing log file if available. This ensures that old entrys will not be overwritten when this script gets sourced.
if (file.exists(log_file)) {
  existing_log <- read.csv(log_file, stringsAsFactors = FALSE)
} else {
  existing_log <- tibble::tibble() # if first entry create a tibble
}

# Combination of existing log with new log entry
qc_log_complete <- bind_rows(existing_log, qc_log_piezometer)

# safe the results as .csv
write.csv(qc_log_complete, log_file, row.names = FALSE)

# Ausgabe
cat("✓ QC Log gespeichert:", nrow(qc_log_piezometer), "neue Einträge\n")
cat("✓ Gesamt im Master-Log:", nrow(qc_log_complete), "Einträge\n")

# ===== CONTINUATION WITH TEMPORAL CONSISTENCY CHECKS =====
# Prepairing experimental dataframe for further analysis... Filter "DELETE" and "REVIEW"
interval_check <- interval_check %>%
  filter(!(Flags %in% c("DELETE", "REVIEW")) | is.na(Flags))

# STEP 4 Summary and rows extraction workflow after "DELETE" and "REVIEW" removed.
interval_summary <- sum_timediff(
  df = interval_check,
  id_col = id_column,
  date_col = date_column,
  td_col = output_column
)
cat("\n=== Interval Summary by Piezometer group ===\n")
print(interval_summary, n = Inf)

# Visual determination of rows with temporal inconsistencies with function_interval_determination.R
temporal_issues_rows <- check_temporal_inconsistencies(
  df = interval_check,
  id_col = id_column,
  date_col = date_column,
  timediff_col = timediff_column
)
print(temporal_issues_rows)

# STEP 5: Verification if all maintenance related columns have been removed completely
temporal_issues_rows <- temporal_issues_rows %>%
  as.data.frame(temporal_issues_rows) %>%
  select(all_of(maintenance_info_columns)) %>%
  is.na(all_of(maintenance_info_columns))


# ========== CLEANUP SECTION ==========
# Remove temporary objects, keep only:
# - data (main dataframe with new flags)
# - qc_stats_[workflow_name] (for reporting)
