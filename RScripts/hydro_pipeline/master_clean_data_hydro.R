#=================================================================================================================
# Script name: master_clean_data_hydro.R
# Goal(s):
  # Orchestrating the individual Scripts, configs and function to generate clean data from all hydrological  measurement devices.
# Author: Kai Albert Zwießler
# Date: 2025.12.24

#=================================================================================================================
# ==============================================================================
# HYDRO PIPELINE MASTER SCRIPT
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
PIPELINE_STEP <- "start"  # Track current step
KEEP_INTERMEDIATE <- FALSE  # For debugging, set FALSE for production

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
}

# Optional: Save checkpoint
if (KEEP_INTERMEDIATE) {
  saveRDS(data_standardized, "results/pipeline_debugging/01_data_standardized.rds")
}

# 2. Load Functions for Temporal Consistency workflow
source("RScripts/utils/qc_functions/function_time.R")
source("RScripts/utils/qc_functions/function_timediff_sum.R")
source("RScripts/utils/qc_functions/function_interval_determination.R")
source("RScripts/utils/qc_functions/function_coordinate_transformation.R")
source("RScripts/utils/qc_functions/function_apply_qc_flags.R")
source("RScripts/utils/qc_functions/function_log_qc_flags.R")

# 3. QC Step 1: Temporal consistency
source("RScripts/hydro_pipeline/02_quality_control/02_qc_temporal_consistency_pz.R")

# Verify expected outputs
if (!exists("data_qc_temporal")) {
  stop("ERROR: data_qc_temporal not created in step 2")
} else {
  PIPELINE_STEP <- "after_qc_temporal"
}


# ------------------------------------------------------------------------------
# 3. QC - DUPLICATE DETECTION
# ------------------------------------------------------------------------------
cat("\n=== Step 3: QC Duplicate Detection ===\n")
# data_qc_duplicates
# ------------------------------------------------------------------------------
# 4. QC - PHYSICAL PLAUSIBILITY
# ------------------------------------------------------------------------------
cat("\n=== Step 4: QC physical plausibility ===\n")
# data_qc_range

# ------------------------------------------------------------------------------
# FINAL OUTPUT
# ------------------------------------------------------------------------------
cat("\n=== Pipeline Complete ===\n")
cat("Final dataset:", nrow(data_qc_temporal), "rows\n")
# data_final 