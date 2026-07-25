#======================================================================
# Script name: 04_01_temporal_structure_analysis_meteo_hourly.R
# Goal(s): 
  # Preparation to aggregate the data 10_QORIKALIS_18_08_2025.csv to hourly values.
  # Rejoin of aggregated and master data frame meteo
# Author: Kai Albert Zwießler
# Date: 2026.06.15
# Input Dataset:
  # master data frame meteo
# Output: 
# =======================================

# ------------------------------------------------------------------------------
# TEMPORAL AGGREGATION 15-min-Data -> 60 min data aggregation for data sheet 10_QORIKALIS_18_08_2025.csv test before converting it into a function
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

# ------------------------------------------------------------------------------
# Intermediate Verifications of functions vector_mean_wd and aggregate_15min_to_hourly
# ------------------------------------------------------------------------------
# ------ verification of function vector_mean_wd ------
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



# ------ verification of results function aggregate_15min_to_hourly in combination with vector_mean_wd ------
# check if the wind direction is calculated correctly
WD_before <- data_meteo %>%
  dplyr::select(Date, Source.Code, WD)

WD_after <- data_meteo_2 %>%
  dplyr::select(Date, Source.Code, WD)
print(WD_before)
tail(WD_after)
results$data %>%
  dplyr::filter(Date == as.POSIXct("2025-07-07 14:00", tz = TIMEZONE_DATA))



# check for reasonable aggregation compression over the time frame
data_meteo %>%
  filter(Source.Code == "10_QORIKALIS_18_08_2025.csv") %>%
  summarise(
    start = min(Date),
    end   = max(Date),
    total = n()
  )

data_meteo_2 %>%
  filter(Source.Code == "10_QORIKALIS_18_08_2025.csv") %>%
  summarise(
    start = min(Date),
    end   = max(Date),
    total = n()
  )
# RESULT: correct amount of aggregation 935 after and before 3736 with two hours only containing 2 measurements instead of the expected 4.


# check for start and end date for each data sheet
data_meteo_standardized %>%
  group_by(ID) %>%
  summarise(
    min_date = min(Date),
    max_date = max(Date),
    n = n()
  )


# Check temporal structure of all data sets with calc_time_diff and sum_timediff - this step is repeatedly used as the analysis workflow foundation
data_standardized <- calc_time_diff(
  data_standardized,
  id_column = "Source.Code",
  date_column = "Date"
)

timediff_summary <- sum_timediff(
  data_standardized,
  id_column = "Source.Code",
  date_column = "Date",
  timediff_column = "time_diff"
)

print(timediff_summary, n = Inf)
count(data_standardized, Source.Code, time_diff)


