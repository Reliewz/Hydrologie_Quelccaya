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
CURRENT_PIPELINE_STAGE  <- "configuration"  # Track current step
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
source("RScripts/utils/QC_functions/function_clean_header_qk.R")
source("RScripts/utils/QC_functions/function_translate_headers_qk.R")
source("RScripts/utils/qc_functions/function_load_hobo_csv.R")
source("RScripts/utils/qc_functions/function_load_senamhi_csv.R")
source("RScripts/utils/qc_functions/function_rename_columns.R")
source("RScripts/utils/qc_functions/function_ensure_required_columns_qk.R")
source("RScripts/utils/qc_functions/function_parse_datetime_column.R")
source("RScripts/utils/qc_functions/function_drop_columns.R")
source("RScripts/utils/qc_functions/function_load_qk_csv.R")
source("RScripts/utils/QC_functions/function_harmonize_NA_codes.R")
source("RScripts/utils/QC_functions/function_convert_column_types.R")

source("RScripts/utils/qc_functions/function_calc_time_diff.R")
source("RScripts/utils/qc_functions/function_timediff_sum.R")
source("RScripts/utils/qc_functions/function_vector_mean_wd.R")
source("RScripts/utils/qc_functions/function_aggregate_15min_to_hourly.R")
source("RScripts/utils/qc_functions/function_interval_determination.R")
source("RScripts/utils/qc_functions/function_coordinate_transformation.R")
source("RScripts/utils/qc_functions/function_apply_qc_flags.R")
source("RScripts/utils/qc_functions/function_log_qc_decision.R")

if (PIPELINE_MODE == "METEO"){
source("RScripts/meteo_pipeline/00_configuration_meteo/00_config_meteo.R") 
}

if (PIPELINE_MODE == "HYDRO"){
source("RScripts/hydro_pipeline/00_configuration_hydro/00_config_hydro.R")
}


# Define pipeline control variables
CURRENT_PIPELINE_STAGE  <- "load_and_standardize"  # Track current step
KEEP_INTERMEDIATE <- FALSE  # For debugging, set FALSE for production
CURRENT_QC_LEVEL <- NULL
# ------------------------------------------------------------------------------
# 1. LOAD & STANDARDIZE
# ------------------------------------------------------------------------------
cat("\n=== Step 1: Load and Standardize ===\n")

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

if (PIPELINE_MODE == "METEO"){
# Temporal harmonization and documentation steps
source("RScripts/meteo_pipeline/01_import/01_02_temporal_harmonization_meteo15.R")
}

if (PIPELINE_MODE == "HYDRO"){
source("RScripts/meteo_pipeline/01_import/01_02_temporal_harmonization_hydro15.R")
}

# Verify expected outputs were generated
expected_obj <- if (PIPELINE_MODE == "METEO") "data_meteo_standardized" else "data_hydro_standardized"

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
PIPELINE_STEP <- "completeness test"
CURRENT_PIPELINE_STAGE  <- "completeness_test"
if (PIPELINE_MODE == "METEO"){}
if (PIPELINE_MODE == "HYDRO"){}
# ------------------------------------------------------------------------------
# 3a. Basic QC - Level 1.1 - Temporal continuity Gap test date column
# ------------------------------------------------------------------------------
PIPELINE_STEP <- "1.0 temporal continuity"
CURRENT_PIPELINE_STAGE <- "temporal_continuity"

# Source QC script
source("RScripts/hydro_pipeline/02_quality_control/02_qc_temporal_consistency_pz.R")

# Verify expected outputs
if (!exists("data_tc_flagged")) {
  stop("ERROR: data_tc_flagged not created in QC step 2.1 temporal consistency.")
} else {
  PIPELINE_STEP <- "after_tc"
  n_flagged <- sum(!is.na(data_tc_flagged[[TC_FLAGS_COLUMN]]))
  pct_flagged <- round(n_flagged / nrow(data_tc_flagged) * 100, 2)
  
  cat("✓ Flagged", n_flagged, "records (", pct_flagged, "%)\n")
}

# ------------------------------------------------------------------------------
# 3b. QC - Level 1.1 - Tolerance Test - range test
# ------------------------------------------------------------------------------
PIPELINE_STEP <- "1.1 temporal_consistency"
CURRENT_PIPELINE_STAGE <- "range_test"

# ------------------------------------------------------------------------------
# 3c. QC - Level 1.2 - Temporal consistency - step test
# ------------------------------------------------------------------------------
PIPELINE_STEP <- "1.2 temporal_consistency"
CURRENT_PIPELINE_STAGE <- "step_test"
# ------------------------------------------------------------------------------
# 3d. QC - Level 1.3 - Temporal consistency - persistence test
# ------------------------------------------------------------------------------
PIPELINE_STEP <- "1.3 temporal_consistency"
CURRENT_PIPELINE_STAGE <- "persistence_test"

# ------------------------------------------------------------------------------
# 3e. QC - Level 1.4 - Internal Consistency
# ------------------------------------------------------------------------------
PIPELINE_STEP <- "1.4 internal consistency"
CURRENT_QC_LEVEL <- "internal_consistency"



cat("\n=== Step 4: QC physical plausibility ===\n")
# Verify expected outputs
if (!exists("data_qc_duplicates")) {
  stop("ERROR: data_pp_flagged not created in QC step 2.2 physical plausibility.")
} else {
  PIPELINE_STEP <- "after_pp"
  n_flagged <- sum(!is.na(data_pp_flagged[[PP_FLAGS_COLUMN]]))
  pct_flagged <- round(n_flagged / nrow(data_pp_flagged) * 100, 2)
  
  cat("✓ Flagged", n_flagged, "records (", pct_flagged, "%)\n")
}


# ------------------------------------------------------------------------------
# 5. 
# ------------------------------------------------------------------------------

# data_flagged


cat("\n╔════════════════════════════════════════════════════════════╗\n")
cat("║                  PIPELINE COMPLETE                         ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n")

# ------------------------------------------------------------------------------
# FINAL OUTPUT
# ------------------------------------------------------------------------------
PIPELINE_STEP <- "complete"

cat("\n=== Pipeline Complete ===\n")
cat("Final dataset:", nrow(data_final), "rows\n")
