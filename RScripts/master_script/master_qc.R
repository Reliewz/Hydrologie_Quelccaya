#=================================================================================================================
# Script name: master_qc.R
# Goal(s):
  # Orchestrating the individual Scripts, configs and functions to generate clean data from all hydrological or meteorological measurement devices.
# Author: Kai Albert Zwießler
# Date: 2025.12.24

#=================================================================================================================

# ==============================================================================
#  MASTER SCRIPT
# ==============================================================================
# Clear workspace at start
rm(list = ls())

PIPELINE_MODE <- c("METEO", "HYDRO")[menu(
  choices = c("METEO", "HYDRO"),
  title   = "Select pipeline to execute:"
)]

cat(sprintf("Running pipeline: %s\n", PIPELINE_MODE))

#### SOURCES ####

# Define pipeline control variables
PIPELINE_STEP  <- "configuration"  # Track current step
KEEP_INTERMEDIATE <- FALSE  # For debugging, set FALSE for production

# ------------------------------------------------------------------------------
# 0. CONFIGURATION
# ------------------------------------------------------------------------------
cat("=== Loading Configuration ===\n")
# Loading packages for both pipelines
source("RScripts/hydro_pipeline/00_configuration_hydro/00_setup_packages.R")
# ------------------------------------------------------------------------------
# Load Functions
# ------------------------------------------------------------------------------
#Data cleaning and Import functions
source("RScripts/utils/QC_functions/function_clean_header_qk.R")
source("RScripts/utils/QC_functions/function_translate_headers_qk.R")
source("RScripts/utils/qc_functions/function_load_hobo_csv.R")
source("RScripts/utils/qc_functions/function_load_senamhi_csv.R")
source("RScripts/utils/qc_functions/function_rename_columns.R")
source("RScripts/utils/qc_functions/function_ensure_required_columns_qk.R")
source("RScripts/utils/qc_functions/function_parse_datetime_column.R")
source("RScripts/utils/qc_functions/function_drop_columns.R")
source("RScripts/utils/qc_functions/function_load_qk_csv.R")


#Harmonization Functions
source("RScripts/utils/QC_functions/function_harmonize_NA_codes.R")
source("RScripts/utils/QC_functions/function_convert_column_types.R")
source("RScripts/utils/qc_functions/function_calc_time_diff.R")
source("RScripts/utils/qc_functions/function_timediff_sum.R")
source("RScripts/utils/qc_functions/function_complete_timeseries.R")
source("RScripts/utils/qc_functions/function_vector_mean_wd.R")
source("RScripts/utils/qc_functions/function_aggregate_15min_to_hourly.R")
source("RScripts/utils/qc_functions/function_interval_determination.R")
source("RScripts/utils/qc_functions/function_coordinate_transformation.R")

#QC Tests and Functions for Flagging Workflow
source("RScripts/utils/qc_functions/function_qc_completeness_test.R")
source("RScripts/utils/qc_functions/function_qc_gross_error_check.R")
source("RScripts/utils/qc_functions/function_qc_persistence_test.R")
source("RScripts/utils/qc_functions/function_apply_qc_flags.R")
source("RScripts/utils/qc_functions/function_log_qc_decision.R")

if (PIPELINE_MODE == "METEO"){
source("RScripts/meteo_pipeline/00_configuration_meteo/00_config_meteo.R") 
}

if (PIPELINE_MODE == "HYDRO"){
source("RScripts/hydro_pipeline/00_configuration_hydro/00_config_hydro.R")
}



# ------------------------------------------------------------------------------
# 1. LOAD & STANDARDIZE
# ------------------------------------------------------------------------------
cat("\n=== Step 1: Load and Standardize ===\n")
# Define pipeline control variables
PIPELINE_STEP  <- "load_and_standardize"  # Track current step
KEEP_INTERMEDIATE <- FALSE  # For debugging, set FALSE for production

if (PIPELINE_MODE == "METEO"){
# Load and standardize Station Data QUELCCAYA & SENAMHI meteorological stations
source("D:/RProjekte/Hydrologie_Quelccaya/RScripts/meteo_pipeline/01_import/01_00_import_stationQQ.R")
source("D:/RProjekte/Hydrologie_Quelccaya/RScripts/meteo_pipeline/01_import/01_01_import_SENAMHI_stations.R")
# Load Qori-Kalis meteorological station and standardize meteorological master data frame
source("RScripts/meteo_pipeline/01_import/01_02_load_and_standardize_meteo.R")
}

if (PIPELINE_MODE == "HYDRO"){
source("RScripts/hydro_pipeline/01_import/01_00_load_and_standardize_hydro.R")
}

# Verify expected outputs were generated
expected_obj <- if (PIPELINE_MODE == "METEO") "data_meteo_standardized" else "data_hydro_standardized"

if (!exists(expected_obj)) {
  stop(sprintf("ERROR: %s not created in step 1", expected_obj))
} else {
  PIPELINE_STEP <- "after_load"
}

# Optional: Save checkpoint
if (KEEP_INTERMEDIATE) {
  saveRDS(get(expected_obj), file.path(DIR_CHECKPOINTS, "01_data_standardized.rds"))
}

# ------------------------------------------------------------------------------
# 2. TEMPORAL HARMONIZATION AND DOCUMENTATION
# ------------------------------------------------------------------------------
PIPELINE_STEP  <- "harmonization"  # Track current step
KEEP_INTERMEDIATE <- FALSE

if (PIPELINE_MODE == "METEO"){
# Temporal harmonization and documentation steps
source("RScripts/meteo_pipeline/02_temporal_harmonization_15/02_01_temporal_harmonization_meteo15.R")
}

if (PIPELINE_MODE == "HYDRO"){
source("RScripts/hydro_pipeline/02_temporal_harmonization_15/02_01_temporal_harmonization_hydro15.R")
}

# Verify expected outputs were generated
expected_obj <- if (PIPELINE_MODE == "METEO") "data_meteo15_harmonized" else "data_hydro15_harmonized"

if (!exists(expected_obj)) {
  stop(sprintf("ERROR: %s not created in step 2", expected_obj))
} else {
  PIPELINE_STEP <- "after_harmonization"
}

# Optional: Save checkpoint
if (KEEP_INTERMEDIATE) {
  saveRDS(get(expected_obj), file.path(DIR_CHECKPOINTS, "01_data_harmonized.rds"))
}

# ------------------------------------------------------------------------------
# 3. Basic QC - Level 1 - Completeness Test
# ------------------------------------------------------------------------------
PIPELINE_STEP <- "COMPLETENESS_TEST"
KEEP_INTERMEDIATE <- FALSE  

if (PIPELINE_MODE == "METEO"){
  source("RScripts/meteo_pipeline/03_quality_control_original_temporal_resolution/03_00_qc_completeness_test.R")
  }

if (PIPELINE_MODE == "HYDRO"){
  source("RScripts/hydro_pipeline/03_quality_control_original_temporal_resolution/03_00_qc_completeness_test.R")
  }

# Verify expected outputs were generated
expected_obj <- if (PIPELINE_MODE == "METEO") "data_meteo15_completeness_flagged" else "data_hydro15_completeness_flagged"

if (!exists(expected_obj)) {
  stop(sprintf("ERROR: %s not created in step 2", expected_obj))
} else {
  PIPELINE_STEP <- "after_completeness_test"
}

# Optional: Save checkpoint
if (KEEP_INTERMEDIATE) {
  saveRDS(get(expected_obj), file.path(DIR_CHECKPOINTS, "01_data_completeness_test.rds"))
}

# ------------------------------------------------------------------------------
# 3.1 Basic QC - Level 1 - WMO's Gross Error Check
# ------------------------------------------------------------------------------
PIPELINE_STEP <- "GROSS_ERROR_CHECK"

if (PIPELINE_MODE == "METEO"){
  source("RScripts/meteo_pipeline/03_quality_control_original_temporal_resolution/03_01_qc_gross_error_check.R")
  }

if (PIPELINE_MODE == "HYDRO"){
  source("RScripts/hydro_pipeline/03_quality_control_original_temporal_resolution/03_01_qc_gross_error_check.R")
  }

# Verify expected outputs were generated
expected_obj <- if (PIPELINE_MODE == "METEO") "data_meteo15_gross_error_flagged" else "data_hydro15_gross_error_flagged"

if (!exists(expected_obj)) {
  stop(sprintf("ERROR: %s not created in step 2", expected_obj))
} else {
  PIPELINE_STEP <- "after_gross_error_check"
}

# Optional: Save checkpoint
if (KEEP_INTERMEDIATE) {
  saveRDS(get(expected_obj), file.path(DIR_CHECKPOINTS, "01_data_gross_error.rds"))
}

# ------------------------------------------------------------------------------
# 3.2.1 Basic QC - Level 1 - Temporal Consistency: Persistence Test
# ------------------------------------------------------------------------------
PIPELINE_STEP <- "PERSISTENCE_TEST"

if (PIPELINE_MODE == "METEO"){
  source("RScripts/meteo_pipeline/03_quality_control_original_temporal_resolution/03_02_01_qc_persistence_test.R")}

if (PIPELINE_MODE == "HYDRO"){
  source("RScripts/hydro_pipeline/03_quality_control_original_temporal_resolution/03_02_01_qc_persistence_test.R")}

# Verify expected outputs were generated
expected_obj <- if (PIPELINE_MODE == "METEO") "data_meteo15_persistence_flagged" else "data_hydro15_persistence_flagged"

if (!exists(expected_obj)) {
  stop(sprintf("ERROR: %s not created in step 2", expected_obj))
} else {
  PIPELINE_STEP <- "after_persistence_test"
}

# Optional: Save checkpoint
if (KEEP_INTERMEDIATE) {
  saveRDS(get(expected_obj), file.path(DIR_CHECKPOINTS, "01_data_persistent.rds"))
}


# ------------------------------------------------------------------------------
# 3.2.2 Basic QC - Level 1 - Temporal Consistency: Step test
# ------------------------------------------------------------------------------
PIPELINE_STEP <- "STEP_TEST"

if (PIPELINE_MODE == "METEO"){
  source("RScripts/meteo_pipeline/03_quality_control_original_temporal_resolution/03_02_02_qc_step_test.R")}

if (PIPELINE_MODE == "HYDRO"){
  source("RScripts/hydro_pipeline/03_quality_control_original_temporal_resolution/03_02_02_qc_step_test.R")}

# Verify expected outputs were generated
expected_obj <- if (PIPELINE_MODE == "METEO") "data_meteo15_step_test_flagged" else "data_hydro15_step_test_flagged"

if (!exists(expected_obj)) {
  stop(sprintf("ERROR: %s not created in step 2", expected_obj))
} else {
  PIPELINE_STEP <- "after_step_test"
}

# Optional: Save checkpoint
if (KEEP_INTERMEDIATE) {
  saveRDS(get(expected_obj), file.path(DIR_CHECKPOINTS, "01_data_step.rds"))
}

# ------------------------------------------------------------------------------
# 3.3 BASIC QC - Level 1 - Internal Consistency
# ------------------------------------------------------------------------------
PIPELINE_STEP <- "INTERNAL_CONSISTENCY"

if (PIPELINE_MODE == "METEO"){
  source("RScripts/meteo_pipeline/03_quality_control_original_temporal_resolution/03_03_qc_internal_consistency.R")}

if (PIPELINE_MODE == "HYDRO"){
  source("RScripts/hydro_pipeline/03_quality_control_original_temporal_resolution/03_03_qc_internal_consistency.R")}

# Verify expected outputs were generated
expected_obj <- if (PIPELINE_MODE == "METEO") "data_meteo15_internal_consistency_flagged" else "data_hydro15_internal_consistency_flagged"

if (!exists(expected_obj)) {
  stop(sprintf("ERROR: %s not created in step 2", expected_obj))
} else {
  PIPELINE_STEP <- "after_internal_consistency"
}

# Optional: Save checkpoint
if (KEEP_INTERMEDIATE) {
  saveRDS(get(expected_obj), file.path(DIR_CHECKPOINTS, "01_data_internal_consistency.rds"))
}


cat("\n╔════════════════════════════════════════════════════════════╗\n")
cat("║                  PIPELINE COMPLETE                         ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n")

# ------------------------------------------------------------------------------
# FINAL OUTPUT
# ------------------------------------------------------------------------------
PIPELINE_STEP <- "complete"

cat("\n=== Pipeline Complete ===\n")
cat("Final dataset:", nrow(data_final), "rows\n")
