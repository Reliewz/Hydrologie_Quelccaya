#======================================================================
# Script name: 03_01_analysis_qc_gross_error_check.R
# Goal(s): 
  # Check temperature records of barometer
# Author: Kai Albert Zwießler
  # Date: 2026.07.18
# Input Data set:
  # hydro results gross error calibration list
  # Export of QC summary
# Output: 
  # Knowledge about the range of temperature deviation.
#======================================================================

temp_check <-hydro_results_gross_error_check_calibration[[1]] |> 
  filter(Temp_out_of_range == TRUE) |>
  select(Date, Temp, Source.Code, Connection_off, Connection_on, Host_connected)

print(temp_check, n = Inf)

# lowest measured termperature
temp_check_min <-hydro_results_gross_error_check_calibration[[1]] |> 
  filter(Temp_out_of_range == TRUE & Temp < -7) |>
  select(Date, Temp, Source.Code, Connection_off, Connection_on, Host_connected) |> 
  summarise(min(Temp))

# - 12.7°C

# Export QC summary gross error check HYDRO

readr::write_csv(
  hydro_results_gross_error_check_calibration$detection_summary,
  file.path(
    HYDRO_OUTPUT_DIRECTORIES$DIR_QC_SUMMARY,
    "gross_error_calibraton_summary.csv"
  ))


# Export QC summary gross error check METEO
readr::write_csv(
  meteo_results_gross_error_check$detection_summary,
  file.path(
    METEO_OUTPUT_DIRECTORIES$DIR_QC_SUMMARY,
    "gross_error_check_summary.csv"
  ))