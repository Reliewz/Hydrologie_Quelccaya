#=================================================================================================================
# Script name: function_interval_determination.R
# Function name: check_temporal_inconsistencies()
# Goal(s):
  # The function groups rows according to predefined categories.
  # allows for a "full coverage profile
  # The intervals are < 15min, 15< - <60 min, 60min> - <1440.
# Date: 2025.12.01
#=================================================================================================================

#' @title The functions displays intervals of pre-defined temporal gaps between time steps inside a list.
#' 
#' @description 
#' 
#' @note If time step duplicates exist they will be listed in the category \code{below15} and can be identified by checking the time_diff column
#' 
#' @param df data frame or tibble
#' @param date_col Character string. Column with the temporal information. Default: Date.
#' @param id_col Column that contains the information of the different measurement devices to ensure a device by device analysis
#' @param timediff_col contains the information in minutes. Calculated by the function calc_time_diff()
#' @param categories String to analyze intervals < 15 minutes, > 15 < 60 minutes and >60 minutes. Default: all categories will be analyzed
#' @param thresholds sets the threshold value in minutes. Default: 15, 60
#' @param sort Logical. Should data be sorted within function? Default: TRUE
#' @return A list containing the rows according to predefined \code{categories}.
#'  \itemize{
#'    \item \code{above1440}: Contains the records which temporal gap of examined time steps exceed 1440 minutes (1 day).
#'    \item \code{between60_1440}: Contains the records which temporal gap is situated between 60 minutes and 1440 minutes.
#'    \item \code{between15_60}: Contains the records which temporal gap is situated between 15 minutes and 60 minutes.
#'    \item \code{below15}: Contains the records which temporal gap of examined time steps is below 15 minutes.
#' @author Kai Albert Zwießler
#' @export
check_temporal_inconsistencies <- function(
    df,
    date_col = "Date",
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
    stop("date_col must deliver be a column name in the data frame. ")
  }
  if (!id_col %in% names(df)) {
    stop("id_col must deliver a column name in the data frame. ")
  }    
  if (!timediff_col %in% names(df)) {
    stop("timediff_col must deliver a column name in the data frame. ")
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