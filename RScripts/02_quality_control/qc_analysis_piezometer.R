#=================================================================================================================
# Scriptname: qc_analysis_piezometer.R
# Goal(s): 
  # cleansing of all temporal inconsistencies
  # Examination of "REVIEW" flags assigned by the maintenance-loop.
# Author: Kai Albert Zwießler
# Date: 2025.12.01
# Input Dataset: Piezometer data

#=================================================================================================================

#=== Cleansing of "DELETE" Flags and rerun the sum_timediff function. ====

# STEP 1: left join of flags into the dataframe interval_check who now serves as the experiment df for all temporal consistency checks.
flag_info <- data_raw_flagged %>%
  select(ID, RECORD, Flags)
# Add flag information back to the full dataset
interval_check <- interval_check %>% 
  left_join(flag_info,
            by = c("ID", "RECORD"))

# STEP 2: Filtering DELETED rows into separate data frame for documentation. WIll later be extracted.
deleted_rows <- interval_check %>% 
  filter(Flags == "DELETE")

# Keep all rows that are not "DELETE" also NA values.
filter_interv_check <- interval_check %>%
  filter(Flags != "DELETE" | is.na(Flags))

# ====STEP 3: Filter all rows marked as "REVIEW" =====
filter_interv_check <- interval_check %>%
  filter(Flags != "REVIEW" | is.na(Flags))

# ===== Review Flags analysis =====

# Documentation "REVIEW" flags since there is no information content in the measurement value section
deleted_rows <- interval_check %>% 
  filter(Flags == "DELETE" | Flags == "REVIEW")

# Keep alls rows that are not "DELETE" and "REVIEW"
filter_interv_check <- interval_check %>%
  filter(!(Flags %in% c("DELETE", "REVIEW")) | is.na(Flags))

# STEP 4 Summary and rows extraction workflow after "DELETE" and "REVIEW" removed.
filter_interval_summary <- sum_timediff(
  df = filter_interv_check,
  id_col = id_column,
  date_col = date_column,
  td_col = output_column
)
cat("\n=== Interval Summary by Piezometer group ===\n")
print(filter_interval_summary, n = Inf)

# Visual determination of rows with temporal inconsistencies with function_interval_determination.R
temporal_issues_rows <- check_temporal_inconsistencies(
  df = filter_interv_check,
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
  


