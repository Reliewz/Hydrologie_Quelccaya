#=================================================================================================================
# Scriptname: master_clean_data_meteo.R
# Goal(s):
# Generating clean data from all hydrological  measurement devices.
# Author: Kai Albert Zwießler
# Date: 2025.12.24
# Outputs: 
#=================================================================================================================

#### SOURCES ####
# 1. Load & Standardize
source("RScripts/01_import/00_config_meteo.R")
source("RScripts/01_import/load_and_standardize.R")

# 2. Generic QC functions
source("utils/functions_timediff.R")

# 3. Piezometer QC
source("RScripts/02_QC/QC_piezometers.R")

# 4. Meteorological QC
source("RScripts/02_QC/QC_meteo.R")

# 5. Waterlevel sensor QC
source("RScripts/02_QC/QC_meteo.R")

# 5. Save final clean data
saveRDS(clean_data, "Output/clean_data.RDS")
