#=================================================================================================================
# Script name: master_clean_data_hydro.R
# Goal(s):
  # Orchestrating the individual Scripts, configs and function to generate clean data from all hydrological  measurement devices.
# Author: Kai Albert Zwießler
# Date: 2025.12.24

#=================================================================================================================

# ==============================================================================
# PIEZOMETER, HYDROLOGICAL PIPELINE - MASTER SCRIPT - QUALITY CONTROL
# ==============================================================================
# Clear workspace at start
rm(list = ls())

#### SOURCES ####

# ------------------------------------------------------------------------------
# 0. CONFIGURATION
# ------------------------------------------------------------------------------
cat("=== Loading Configuration ===\n")
source("RScripts/hydro_pipeline/00_configuration/00_setup_packages.R")
source("RScripts/hydro_pipeline/00_configuration/00_config_hydro.R")

# Define pipeline control variables
PIPELINE_STEP <- "load_and_standardize"  # Track current step
KEEP_INTERMEDIATE <- FALSE  # For debugging, set FALSE for production
CURRENT_QC_LEVEL <- NULL
# ------------------------------------------------------------------------------
# 1. LOAD & STANDARDIZE
# ------------------------------------------------------------------------------
cat("\n=== Step 1: Load and Standardize ===\n")
source("RScripts/hydro_pipeline/01_import/01_load_and_standardize.R")

# Verify expected outputs exist
if (!exists("data_standardized")) {
  stop("ERROR: data_standardized not created in step 1")
} else {
PIPELINE_STEP <- "after_load"
cat("✓ Loaded", nrow(data_standardized), "records\n")
}

# Optional: Save checkpoint
if (KEEP_INTERMEDIATE) {
  saveRDS(data_standardized, file.path(dir_checkpoints, "01_data_standardized.rds"))
}

# 2. Load Functions for Temporal Consistency workflow
source("RScripts/utils/qc_functions/function_time.R")
source("RScripts/utils/qc_functions/function_timediff_sum.R")
source("RScripts/utils/qc_functions/function_interval_determination.R")
source("RScripts/utils/qc_functions/function_coordinate_transformation.R")
source("RScripts/utils/qc_functions/function_apply_qc_flags.R")
source("RScripts/utils/qc_functions/function_log_qc_flags.R")

# ------------------------------------------------------------------------------
# 3. QC - Level 1 - Temporal consistency
# ------------------------------------------------------------------------------
PIPELINE_STEP <- "temporal_consistency"
CURRENT_QC_LEVEL <- "2.1 - temporal consistency"

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
# 4. QC - PHYSICAL PLAUSIBILITY
# ------------------------------------------------------------------------------
PIPELINE_STEP <- "physical_plausbility"
CURRENT_QC_LEVEL <- "2.2 - physical_plausibility"

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
