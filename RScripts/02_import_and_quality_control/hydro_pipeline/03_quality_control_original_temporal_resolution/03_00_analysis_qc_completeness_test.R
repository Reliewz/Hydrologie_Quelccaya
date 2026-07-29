#======================================================================
# Script name: 03_01_analysis_qc_completeness_test.R
# Goal(s): 
  # Export summaries
# Author: Kai Albert Zwießler
  # Date: 2026.07.18
# Input Data set:
  # hydro standardized data frame
# Output: 
  # summary reports
#======================================================================

# Export QC summary completeness test HYDRO

readr::write_csv(
  hydro_results_completeness_test$detection_summary,
  file.path(
    HYDRO_OUTPUT_DIRECTORIES$DIR_QC_SUMMARY,
    "HYDRO_completeness_test_summary.csv"
  ))


# Export QC summary completeness test METEO
readr::write_csv(
  meteo_results_completeness_test$detection_summary,
  file.path(
    METEO_OUTPUT_DIRECTORIES$DIR_QC_SUMMARY,
    "METEO_completeness_test_summary.csv"
  ))