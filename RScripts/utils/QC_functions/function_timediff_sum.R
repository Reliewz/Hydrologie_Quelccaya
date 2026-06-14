#======================================================================
# Scriptname: utils/function_timediff_sum.R
# Function name: sum_time_diff()
# Goal(s): 
# Generating a function that summarizes the state of the Date column in context of temporal consistency. To evaluate the changes of preprocessing steps.
  # mean value, max/min, total rows, 
  # Count of: 15 min time steps, 60 min time steps, 15 - 60 min time steps > 60 min, < 15min.
# Temporal Consistency test
# Author: Kai Albert Zwießler
# Date: 2025.11.29
#======================================================================

#' @details sum_timediff - Summarizes the results of the calc_time_diff function.
#' Required: df must contain the time-difference column produced by cal_time_diff()
#' Generic funtion for piezometer, WLS, meteorological stations.
#' # ========== CONFIGURATION ==========
#' @param df data.frame
#' @param id_column string: Name of the ID-column
#' @param date_column string: Name of Date-Column (default "Date")
#' @param timediff_column column containing the calculated differences of time steps. Usually the generated output of calc_time_diff()
#' @return Summarizes the results of the calc_time_diff - function.
#' @export
# ==========  Analyze intervals per group ==========

# Function name
sum_timediff <- function(df,
                          id_column,
                          date_column = "Date",
                          timediff_column) {

  id_column   <- rlang::sym(id_column)
  date_column <- rlang::sym(date_column)
  timediff_column   <- rlang::sym(timediff_column)

  # Basic input checks
  if (!is.data.frame(df)) stop("`df` must be a data.frame or tibble.")
  if (!id_column %in% names(df)) stop(paste0("ID column '", id_column, "' not found in df."))
  if (!date_column %in% names(df)) stop(paste0("Date column '", date_column, "' not found in df."))
  if (!timediff_column %in% names(df)) stop(paste0("time-diff column '", timediff_column, "' not found in df."))   
  
interval_summary <- df %>%
  arrange(!!id_column, !!date_column) %>%
  filter(!is.na(!!timediff_column)) %>%
  group_by(!!id_column) %>%
  summarise(
    n_measurements = n(),
    min_interval = min(!!timediff_column),
    max_interval = max(!!timediff_column),
    average_interval = mean(!!timediff_column),
    n_15min = sum(!!timediff_column == 15), # Count specific intervals:
    n_60min = sum(!!timediff_column == 60),
    n_between = sum(!!timediff_column > 15 & !!timediff_column < 60),
    n_above_60 = sum(!!timediff_column > 60),   # gaps!
    n_below_15 = sum(!!timediff_column < 15),  # Unexpected values potentially in connection with maintenance and sensor errors
    .groups = "drop" # same effect than the command ungroup(), special for summarize.
  )

  return(interval_summary)    
    
}