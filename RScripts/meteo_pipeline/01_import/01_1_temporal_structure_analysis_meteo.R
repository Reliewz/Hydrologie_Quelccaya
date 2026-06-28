#======================================================================
# Scriptname: 01_1_temporal_structure_analysis_meteo.R
# Goal(s): 
  # Analysis of the time steps of each individual input data using Source.Code diferenciation
  # Preparation to aggregate the data to hourly values.
# Author: Kai Albert Zwießler
# Date: 2026.06.15
# Input Dataset:
  # United meteorological data separated by Source.Code and later ID column
  # QUISOQUEPINA_joined.xslx
  # SIBINACHOCHA_joined.xlsx
# Output: 
  # Information concerning
    # Dominant temporal resolution (60 min) and detemrination target temporal resolution (60 min) for aggregation/temporal harmonization script
  # Made decision, stored in a log entry and its export.

# =======================================

# Check temporal structure of data set with calc_time_diff and sum_timediff - this step is repeatedly used as the analysis workflow foundation
data_meteo <- calc_time_diff(
  data_meteo,
  id_column = "Source.Code",
  date_column = "Date"
)

timediff_summary <- sum_timediff(
  data_meteo,
  id_column = "Source.Code",
  date_column = "Date",
  timediff_column = "time_diff"
)

print(timediff_summary, n = Inf)
count(data_meteo, Source.Code, time_diff)

# dominant intervall determination
dominant_interval <- data_meteo %>%
group_by(Source.Code) %>%
  summarise(
    dominant_interval =
      names(which.max(table(time_diff)))
  )
print(dominant_interval, n = Inf)


# ------------------------------------------------------------------------------
# Duplicates in SIBINACHOCHA and QUISOQUEPINA joined .xlsx datasets
# ------------------------------------------------------------------------------

# Analysis of duplicates in date column min_interval > 1. 
duplicate_dates <- data_meteo %>%
  group_by(Source.Code, Date) %>%
  summarise(
    n = n(),
    .groups = "drop"
  ) %>%
  filter(n > 1)
# Show results
count(duplicate_dates, Source.Code)

# Deeper analysis of the data sets with min_interval >1
duplicate_dates <- data_meteo %>%
  group_by(Source.Code, Date) %>%
  filter(n() > 1) %>%
  arrange(Date)
duplicate_dates %>%
  summarise(
    first_duplicate = min(Date),
    last_duplicate = max(Date),
    n_duplicates = n()
  )

# extract duplicates
duplicates <- data_meteo %>%
  group_by(Source.Code, Date) %>%
  filter(n() > 1) %>%
  ungroup()

# check if for the grouped date pairs a difference in the measurement columns exist
duplicate_check <- duplicates %>%
  group_by(Source.Code, Date) %>%
  summarise(
    across( # across applies the following function to all columns
      all_of(METEO_MEASUREMENT_COLUMNS), # all_off combined with across dplyr logic
      ~ n_distinct(.x, na.rm = FALSE) # n_distinct count how many different value pairs exist. #na.rm not ignoring NA values
    ), # .x control variable inserting each column of each from the previous commands. ~ short way for a function call.
    .groups = "drop" # drop group logic good practice, for summarise command.
  ) %>%
  mutate(
    has_conflict = if_any(
      all_of(METEO_MEASUREMENT_COLUMNS),
      ~ .x > 1
    )
  )
count(duplicate_check, Source.Code, has_conflict)
# No differences exist the data set has real duplicates and can therefore be removed.
# Documentation of this decision


# ------------------------------------------------------------------------------
# 15-min-Data -> 60 min data aggregation for data sheet 10_QORIKALIS_18_08_2025.csv test before converting it into a function
# ------------------------------------------------------------------------------
# verification that all time steps are represented by an equal number
data_meteo %>%
  filter(Source.Code == "10_QORIKALIS_18_08_2025.csv") %>%
  mutate(
    minute = lubridate::minute(Date)
  ) %>%
  count(minute)

# Data set selection
qorikalis_15min <- data_meteo %>%
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

# prepare function for Wind direction aggregation
vector_mean_wd <- function(x){
  
  x <- as.numeric(x)
  x <- x[!is.na(x)]
    if(length(x) == 0)
    return(NA_real_)
  u <- mean(sin(x * pi / 180)) # sinus describes east and west component of the vector
  v <- mean(cos(x * pi / 180)) # cosinus describes north and south component of the vector
  wd <- atan2(u, v) * 180 / pi # calculate angle from mean vector. atan2 differenciates between 4 cardinal directions
  (wd + 360) %% 360 # negative angel -> positive
}

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
data_meteo <- data_meteo %>%
  filter(Source.Code != "10_QORIKALIS_18_08_2025.csv")
data_meteo <- bind_rows(
  data_meteo,
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
# check if the written function works correctly and its results differentiates substantially if wind directions are highly distinct
vector_mean_wd(c(350, 10))

# check if the wind direction is calculated correctly
WD_before <- data_meteo %>%
  dplyr::select(Date, Source.Code, WD)

WD_after <- data_meteo_2 %>%
  dplyr::select(Date, Source.Code, WD)
print(WD_before)
tail(WD_after)
results$data %>%
  dplyr::filter(Date == as.POSIXct("2025-07-07 14:00:00", tz = "UTC"))


results$data %>%
  dplyr::filter(Source.Code == "10_QORIKALIS_18_08_2025.csv") %>%
  head(10)