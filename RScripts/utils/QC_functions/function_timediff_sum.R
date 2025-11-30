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

#' @details sum_timediff - Summarizes the results of the timediff() function.
#' Required: df must contain the time-difference column produced by cal_time_diff()
#' Generic funtion for piezometer, WLS, meteorological stations.
#' # ========== CONFIGURATION ==========
#' @param df data.frame
#' @param id_col string: Name of the ID-column
#' @param date_col string: Name of Date-Column (default "Date")
#' @return Summarizes the results of the timediff() function.
#' @export
# ==========  Analyze intervals per group ==========

# Function name
sum_timediff <- function(df,
                          id_col,
                          date_col,
                          td_col) {

  id_column   <- rlang::sym(id_col)
  date_column <- rlang::sym(date_col)
  td_column   <- rlang::sym(td_col)

  # Basic input checks
  if (!is.data.frame(df)) stop("`df` must be a data.frame or tibble.")
  if (!id_col %in% names(df)) stop(paste0("ID column '", id_col, "' not found in df."))
  if (!date_col %in% names(df)) stop(paste0("Date column '", date_col, "' not found in df."))
  if (!td_col %in% names(df)) stop(paste0("time-diff column '", td_col, "' not found in df."))   
  
interval_summary <- df %>%
  arrange(!!id_column, !!date_column) %>%
  filter(!is.na(!!td_column)) %>%
  group_by(!!id_column) %>%
  summarise(
    n_measurements = n(),
    min_interval = min(!!td_column),
    max_interval = max(!!td_column),
    average_interval = mean(!!td_column),
    n_15min = sum(!!td_column == 15), # Count specific intervals:
    n_60min = sum(!!td_column == 60),
    n_between = sum(!!td_column > 15 & !!td_column < 60),
    n_above_60 = sum(!!td_column > 60),   # gaps!
    n_below_15 = sum(!!td_column < 15),  # Unexpected values potentially in connection with maintenance and sensor errors
    .groups = "drop" # same effect than the command ungroup(), special for summarize.
  )

  return(interval_summary)    
    
}