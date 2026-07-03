#======================================================================
# Script name: 01_01_temporal_structure_analysis_meteo.R
# Goal(s): 
  # Detection of different NA codes used in the meteorological data sets
  # Analysis of the time steps of each individual input data using Source.Code differentiation
  # duplicates in time steps analysis
  # completing missing time steps for hourly and 15 minute data
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

# ------------------------------------------------------------------------------
# NA code analysis
# ------------------------------------------------------------------------------
# Identify common NA codes METEO
for(col in METEO_MEASUREMENT_COLUMNS){
  
  cat("\n", col, "\n")
  
  print(
    data_meteo_standardized %>%
      filter(.data[[col]] %in% c("", "-999", "N/A",  "S/D")) %>% #.data to check in the data frame and to transform the character string with the column names
      # to a select-able column inside the data frame. Same as symbol conversion.
      count(.data[[col]])
  )
}


# Check temporal structure of data set with calc_time_diff and sum_timediff - this step is repeatedly used as the analysis workflow foundation
data_meteo_standardized <- calc_time_diff(
  data_meteo_standardized,
  id_column = "Source.Code",
  date_column = "Date"
)

timediff_summary <- sum_timediff(
  data_meteo_standardized,
  id_column = "Source.Code",
  date_column = "Date",
  timediff_column = "time_diff"
)

print(timediff_summary, n = Inf)
count(data_meteo_standardized, Source.Code, time_diff)

# dominant intervall determination
dominant_interval <- data_meteo_standardized %>%
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
duplicate_dates <- data_meteo_standardized %>%
  group_by(Source.Code, Date) %>%
  summarise(
    n = n(),
    .groups = "drop"
  ) %>%
  filter(n > 1)
# Show results
count(duplicate_dates, Source.Code)

# Deeper analysis of the data sets with min_interval >1
duplicate_dates <- data_meteo_standardized %>%
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
duplicates <- data_meteo_standardized %>%
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

# ----------- Repeat workflow check duplicate dates on sensor basis after removement of individual files -------------
duplicate_dates <- data_meteo_standardized %>%
  group_by(ID, Date) %>%
  summarise(
    n = n(),
    .groups = "drop"
  ) %>%
  filter(n > 1)
# Show results
count(duplicate_dates, ID)

# check if measurement columns have equal values
duplicate_dates <- data_meteo_standardized %>%
  group_by(ID, Date) %>%
  filter(n() > 1) %>%
  arrange(Date)
duplicate_dates %>%
  summarise(
    first_duplicate = min(Date),
    last_duplicate = max(Date),
    n_duplicates = n()
  )
print(duplicate_dates, n = Inf)

duplicate_check <- duplicates %>%
  group_by(ID, Date) %>%
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
count(duplicate_check, ID, has_conflict)

# ==============================================================
# 15 - minute time step workflow for 10_QORIKALIS_18_08_2025.csv
# ==============================================================
# ------------------------------------------------------------------------------
#  Gap-filling - Complete missing time steps 10_QORIKALIS_18_08_2025.csv
# ------------------------------------------------------------------------------
# number of rows for later comparison
data_meteo_standardized %>%
  count(Source.Code)

# Isolate "10_QORIKALIS_18_08_2025.csv" as it contains 15 minute time steps
qk15 <- data_meteo_standardized %>%
  filter(Source.Code == "10_QORIKALIS_18_08_2025.csv")

# arrange for good practice
qk15 <- qk15 %>%
  arrange(Date)

# complete for gap filling
qk15 <- qk15 %>%
  tidyr::complete(
    Date = seq(
      min(Date),
      max(Date),
      by = "15 min"
    )
  )

qk15 %>%
  filter(Source.Code == "10_QORIKALIS_18_08_2025.csv") %>%
  summarise(
    start = min(Date, 5),
    end   = max(Date, 5),
    total = n()
  )

# number of rows for later comparison
data_meteo_standardized %>%
  count(Source.Code)

head(qk15, 5)
tail(qk15, 5)
