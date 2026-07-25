#======================================================================
# Script name: 01_01_temporal_structure_analysis_hydro15.R
# Goal(s): 
  # Detection of different NA codes used in the hydrological data sets 
  # Analysis of the time steps of each individual input data using Source.Code differentiation
  # Identifying maintenance event patterns
  
# Author: Kai Albert Zwießler
# Date: 2026.06.15
# Input Data set:
  # United hydrological data separated by Source.Code and later ID column
# Output: 
  # Information concerning
    # Dominant temporal resolution (60 min) and determination target temporal resolution (60 min) for aggregation/temporal harmonization script
  # Made decision, stored in a log entry and its export.

# =======================================

# ------------------------------------------------------------------------------
# NA code analysis
# ------------------------------------------------------------------------------

# Identify common NA codes HYDRO
for(col in HYDRO_MASTER_DF_FRAMEWORK$MEASUREMENT_COLUMNS){
  
  cat("\n", col, "\n")
  
  print(
    data_hydro_standardized %>%
      filter(.data[[col]] %in% c("", "-999", "N/A",  "S/D")) %>% #.data to check in the data frame and to transform the character string with the column names
      # to a select-able column inside the data frame. Same as symbol conversion.
      count(.data[[col]])
  )
}
# RESULT: No differentiation for missing_codes

# Check temporal structure of each individual data sheet with calc_time_diff and sum_timediff - this step is repeatedly used as the analysis workflow foundation
data_hydro_standardized <- calc_time_diff(
  data_hydro_standardized,
  id_column = "Source.Code",
  date_column = "Date"
)

timediff_summary <- sum_timediff(
  data_hydro_standardized,
  id_column = "Source.Code",
  date_column = "Date",
  timediff_column = "time_diff"
)

print(timediff_summary, n = Inf)
count(data_hydro_standardized, Source.Code, time_diff)

# dominant interval determination
dominant_interval <- data_hydro_standardized %>%
group_by(Source.Code) %>%
  summarise(
    dominant_interval =
      names(which.max(table(time_diff)))
  )
print(dominant_interval, n = Inf)

# ------------------------------------------------------------------------------
# Analysis maintenance columns / Data collection artefacts HOBO Loggers fragmented time steps
# ------------------------------------------------------------------------------
# Identify rows with NA in both measurement columns and safe it for further examination in the data frame rows_with_na
rows_with_both_na <- data_hydro_standardized %>%
  filter(
    if_all(
      all_of(HYDRO_MASTER_DF_FRAMEWORK$MEASUREMENT_COLUMNS),
      is.na
    )
  )

# Summary
rows_with_both_na %>%
  summarise(across(all_of(HYDRO_MASTER_DF_FRAMEWORK$MEASUREMENT_COLUMNS), ~ sum(is.na(.x))))
print(rows_with_both_na, n = 10)
# 298 records in total

# Determine all possible combination and count how often they appear.
rows_with_both_na %>%
  count(
    Connection_off,
    Connection_on,
    Host_connected,
    Data_end,
    Angehalten,
    sort = TRUE
  )

# ------------------------------------------------------------------------------
# Duplicates
# ------------------------------------------------------------------------------

# Analysis of duplicates in date column min_interval > 1. 
duplicate_dates <- data_hydro_standardized %>%
  group_by(Source.Code, Date) %>%
  summarise(
    n = n(),
    .groups = "drop"
  ) %>%
  filter(n > 1)
# Show results
count(duplicate_dates, Source.Code)

# Check for duplicates on sensor basis
duplicate_dates <- data_hydro_standardized %>%
  group_by(ID, Date) %>%
  summarise(
    n = n(),
    .groups = "drop"
  ) %>%
  filter(n > 1)
# Show results
count(duplicate_dates, ID)









# ------------------------------------------------------------------------------
# 15-min-Data -> 60 min data aggregation for data sheets test before appling the written function
# ------------------------------------------------------------------------------
# verification that all time steps are represented by an equal number
data_hydro_standardized %>%
  filter(Source.Code == "10_QORIKALIS_18_08_2025.csv") %>%
  mutate(
    minute = lubridate::minute(Date)
  ) %>%
  count(minute)

# Data set selection
qorikalis_15min <- data_hydro_standardized %>%
  filter(Source.Code == "10_QORIKALIS_18_08_2025.csv")
nrow(qorikalis_15min) # verification expected 3736

# Generate hourly values >60 min values are untouched from this operation
qorikalis_15min %>%
  mutate(Date_hour = floor_date(Date, "hour")) %>%
  distinct(Date_hour) %>%
  nrow()

# check for uncomplete hour
qorikalis_15min %>%
  mutate(Date_hour = floor_date(Date, "hour")) %>%
  count(Date_hour) %>%
  count(n)
# identification uncomplete hour
qorikalis_15min %>%
  mutate(Date_hour = floor_date(Date, "hour")) %>%
  count(Date_hour) %>%
  filter(n != 4)
# check uncomplete hour in detail and its measurement values
qorikalis_15min %>%
  mutate(Date_hour = floor_date(Date, "hour")) %>%
  filter(Date_hour %in% as.POSIXct(c(
    "2025-07-07 14:00:00",
    "2025-08-15 12:00:00"
  ), tz = TIMEZONE_DATA)) %>%
  arrange(Date)



# check for min and max intervals within one hour
qorikalis_15min %>%
  mutate(Date_hour = floor_date(Date, "hour")) %>%
  count(Date_hour) %>%
  summarise(
    min_n = min(n),
    max_n = max(n)
  )



# Aggregation from 15-minute to hourly values
qorikalis_hourly <- qorikalis_15min %>%
  mutate(Date_hour = floor_date(Date, "hour")) %>%
  group_by(
    ID,
    Source.Code,
    Date = Date_hour
  ) %>%
  summarise(
    AirTC = mean(AirTC, na.rm = TRUE),
    RH = mean(RH, na.rm = TRUE),
    Precip = sum(Precip, na.rm = TRUE),
    WS = mean(WS, na.rm = TRUE),
    Wind_gust = max(Wind_gust, na.rm = TRUE),
    WD = vector_mean_wd(WD),
    Dew_point = mean(Dew_point, na.rm = TRUE),
    .groups = "drop"
  )

# ---------------------- Verification stage -----------------------------
nrow(qorikalis_hourly)
# expected: 935


# Check for duplicated time stamps
qorikalis_hourly %>%
  count(Date) %>%
  filter(n > 1)

# Check temporal resolution after aggregation
qorikalis_hourly %>%
  arrange(Date) %>%
  mutate(
    time_diff = as.numeric(
      difftime(Date, lag(Date), units = "mins")
    )
  ) %>%
  count(time_diff)


# Substitute data set 10_QORIKALIS_18_08_2025.csv
data_hydro_standardized <- data_hydro_standardized %>%
  filter(Source.Code != "10_QORIKALIS_18_08_2025.csv")
data_hydro_standardized <- bind_rows(
  data_hydro_standardized,
  qorikalis_hourly
)

# check especially for wind direction aggregation behavior
summary(qorikalis_hourly$WD)
range(qorikalis_hourly$WD, na.rm = TRUE)
# check for values with only 2 records
qorikalis_hourly %>%
  filter(Date %in% as.POSIXct(
    c("2025-07-07 14:00:00",
      "2025-08-15 12:00:00"),
    tz = TIMEZONE_DATA
  ))



# ------------------------------------------------------------------------------
# Analysis of maintenance columns
# ------------------------------------------------------------------------------
# Identify rows with NA in on of the two measurement columns and safe it for further examination in the data frame rows_with_na
rows_with_na <- data_standardized %>%
  mutate(
    row_id = row_number(), # extracts the original row number from the dataset. Because filter() function would assign new ones.
    has_any_na = if_any(all_of(measurement_columns), is.na)) %>% # if one of the two is NA it gets stored in the object has_any_na
  filter(has_any_na == TRUE) # Since the output of is.na() function is logical (TRUE/FALSE) == makes sure that only outputs with TRUE get filtered.

# Summary
rows_with_na %>%
  summarise(across(all_of(measurement_columns), ~ sum(is.na(.x))))

documentation <- data_hydro_standardized %>%
  filter(if_all(all_of(HYDRO_MASTER_DF_STANDARDIZED$HYDRO_MEASUREMENT_COLUMNS), is.na
  ))