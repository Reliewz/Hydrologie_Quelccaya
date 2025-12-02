#====================================================================
# Skriptname: qc_analysis_QoriKalis_meteorological_data.R
# Goals:
  # Analyzing the identified missing values and determining the period of missing values of WS, WD, WS_Max
  # 

# Author: Kai Albert Zwießler
# Date: 2025.11.06
# Input Dataset: processed/QoriKalis_merged.xlsx
# Outputs: 
# figures/.png
# tables/
#===================================================================

# ====STEP 1: Identifing the time period of missing values from Wind data.====
missing_wind_timeperiod <- rows_with_na %>%
  filter(is.na(WS)) %>%
  arrange(!!sym(id_column), !!sym(date_column))

  
head(missing_wind_timeperiod)
tail(missing_wind_timeperiod)
  