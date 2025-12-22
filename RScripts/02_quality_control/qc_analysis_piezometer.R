#=================================================================================================================
# Scriptname: qc_analysis_piezometer.R
# Goal(s): 
  # cleansing of all temporal inconsistencies
  # Examination of "REVIEW" flags assigned by the maintenance-loop.
# Author: Kai Albert Zwießler
# Date: 2025.12.01
# Input Dataset: Piezometer data

#=================================================================================================================

#=== Cleansing of "DELETE" Flags and re-run the sum_timediff function. ====

# Add flag information back to experimental data set for temporal consistency checks
interval_check <- interval_check %>% 
  left_join(flag_info,
            by = c("ID", "RECORD"))

# STEP 2: Isolating DELETED rows for documentation.
deleted_rows <- interval_check %>% 
  filter(Flags == "DELETE")

# Creating a tibble for documentation
qc_log_piezometer <- tibble::tibble()

# Documentation of QC Flags using function log_qc_flags
qc_log_piezometer <- bind_rows(
  qc_log_piezometer, 
  log_qc_flags(
  df = deleted_rows,
  action = "initial_assignment",
  to_flag = 'DELETE',
  reason = "The following rows add no additional information content to analysis. (NA values in measurement columns). Protocolled  maintenance or data collection events caused the sensor to lose it´s connection. For further analysis this rows will be excluded."
  ))

# Keep all rows that are not "DELETE" also keep NA values.
interval_check %>%
  filter(Flags != "DELETE" | is.na(Flags))

# ====STEP 3: Filter all rows marked as "REVIEW" =====
# Documentation "REVIEW" flags since there is no information content in the measurement value section
review_rows <- interval_check %>% 
  filter(Flags == "REVIEW")

interval_check %>%
  filter(Flags != "REVIEW" | is.na(Flags))

# ===== Review Flags analysis =====



# Keep alls rows that are not "DELETE" and "REVIEW"
interval_check %>%
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
  


