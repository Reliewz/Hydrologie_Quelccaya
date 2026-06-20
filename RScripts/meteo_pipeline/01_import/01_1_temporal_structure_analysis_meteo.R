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

# Check temporal structure of data set with calc_time_diff and sum_timediff
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
# No differences exist the dataset has real duplicates and can therefore be removed.
# Documentation of this decision

# Verification if the right amount of columns is removed after the harmonization step
n_before <- nrow(data_meteo)
n_after <- nrow(data_meteo)
removed_duplicates <- n_before - n_after
