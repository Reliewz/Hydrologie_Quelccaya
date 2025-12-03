#=================================================================================================================
# Scriptname: function_interval_determination.R
# Goal(s):
  # The function analyses different intervals in context of the temporal consistency analysis.
  # The intervals are < 15min, 15< - <60 min, 60min> - <1440.
# Author: Kai Albert Zwießler
# Date: 2025.12.01
# Outputs: 
#=================================================================================================================

#' Function name: check_temporal_inconsistencies()
#' The functions calculates intervals of different time steps and safes the respective rows according to set categories into a list.
#' @param date_col Column with the temporal information usually "Date"
#' @param id_col Column that contains the information of the different measurement devices to ensure a device by device analysis
#' @param df data frame
#' @param timediff_col contains the information in minutes. Calculated by the function calc_time_diff()
#' @param categories String to analyze intervals < 15 minutes, > 15 < 60 minutes and >60 minutes. Default: all categories will be analyzed
#' @param thresholds sets the threshold value in minutes. Default: 15, 60
#' @param sort Logical. Should data be sorted within function? Default: TRUE
#' @return List containing data frames for each selected category
#' 

check_temporal_inconsistencies <- function(
    df,
    date_col,
    id_col,
    timediff_col,
    categories = c("below15", "between15_60", "between60_1440", "above1440"),
    thresholds = c(15, 60, 1440),
    sort = TRUE
) {
  # Input validation
    # 1. Check if data frame has right type
  if (!is.data.frame(df)){
    stop("df must be a data.frame or tibble.")
  }
  
  # 2. Check if columns exist
  if (!date_col %in% names(df)) {
    stop("Date_column must deliver be a column name in the data frame. Standard 'Date'")
  }
  if (!id_col %in% names(df)) {
      stop("ID_column must deliver a column name in the data frame. Standard 'ID'")
  }    
  if (!timediff_col %in% names(df)) {
        stop("timediff_column must deliver a column name in the data frame. Standard 'time_diff'")
  }

  # 3. Prüfe ob thresholds numerisch und sortiert sind
  if (!is.numeric(thresholds)) {
    stop("thresholds must be numeric.")
  }
  if (!all(thresholds == sort(thresholds))) {
    stop("thresholds must be in ascending order (e.g., c(15, 60, 1440)).")
  }
  
  
  # converting strings into symbols dplyr logic.
  id_column <- rlang::sym(id_col)
  date_column <- rlang::sym(date_col)
  timediff_column <- rlang::sym(timediff_col)
  
  
  #Sort logic, default data will be sorted. FALSE data will not be sorted.
  if (sort) { # argument inside parentheses default TRUE
df <- df %>%
    group_by(!!id_column) %>%
    arrange(!!id_column, !!date_column) %>%
    ungroup()
    }
  
# creating an empty list where the results will be safed.  
  interval_results <- list()
  
# calculates & safes the time steps > daily timesteps into a list
  if ("above1440" %in% categories) {
    interval_results$above1440 <- df %>%
    filter(!!timediff_column > thresholds[3]) %>%
    mutate(category = "above1440")  
    }

  # calculates the results inbetween 60 min and daily timestep and safes it
  if ("between60_1440" %in% categories) {
    interval_results$between60_1440 <- df %>%
    filter(!!timediff_column < thresholds[3], !!timediff_column > thresholds[2]) %>%
    mutate(category = "between60_1440") 
    }  
  
# calculates the results inbetween 60 min and daily timestep and safes it
  if ("between15_60" %in% categories) {
    interval_results$between15_60 <- df %>%
    filter(!!timediff_column > thresholds[1], !!timediff_column < thresholds[2]) %>%
    mutate(category = "between15_60")  
    }  
  
 # calculates the time steps below 15 minutes  and safes it into a list
  if ("below15" %in% categories){ 
  interval_results$below15 <- df %>% 
  filter(!!timediff_column < thresholds[1]) %>%
  mutate(category = "below15")
  }
  
return(interval_results)
}  


  