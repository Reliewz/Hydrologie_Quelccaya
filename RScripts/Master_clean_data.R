#=================================================================================================================
# Scriptname: Master_clean_data.R
# Goal(s):
  # Generating clean data from all meteorological stations with their respective workflows.
# Author: Kai Albert Zwießler
# Date: YYYY.MM.DD
# Outputs: 
#=================================================================================================================

#### SOURCES ####
# 1. Load & Standardize
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
