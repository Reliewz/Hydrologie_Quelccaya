#=================================================================================================================
# Script name: function_check_temporal_inconsistencies.R
# Function name: check_temporal_inconsistencies()
#=================================================================================================================

#' @title Display complete records associated with irregular time intervals. Corresponding records are returned.
#' 
#' @description The function identifies records associated with irregular temporal intervals by evaluating the time differences stored in \code{time_diff_col}.
#' This facilitates the inspection of event log columns (e.g., maintenance or download events), if such information is available in the input data.
#'  
#' The \code{categories} are pre-defined temporal categories.
#' Only intervals differing from the predefined reference intervals are reported. Correct temporal intervals (e.g. 15 minutes, 60 minutes or 1440 minutes) are
#' not reported.
#' 
#' @details The function can be applied on master data frames by specifying \code{id_col} or on single data frames by ignoring \code{id_col}.
#' 
#' The units of \code{categories} and \code{thresholds} are in minutes.
#' The thresholds are predefined as 15, 60, 1440. For the examination of other \code{thresholds} the function needs to be altered.
#' 
#' The function uses fixed reference intervals of 15 minutes, 60 minutes and 1440 minutes (1 day).
#' 
#' A \code{sort} mechanism is applied. Only the returned output is sorted. The input data frame is not modified.
#' 
#' @note The units of \code{categories} and \code{thresholds} are in minutes. The prior calculated time differences done by \code{calc_time_diff}
#' have to be stored in minutes as well. This is a dependency to execute this function.
#' 
#' If duplicates in time steps exist they are reported in the category \code{below15} and can be identified by checking the \code{time_diff_col} for values 0.
#' 
#' 
#' @param df data frame or tibble.
#' @param date_col Character string. Column with the temporal information. Default: Date.
#' @param id_col Character string (Optional). Column that contains the information of the different measurement devices to ensure a device by device analysis
#' @param timediff_col contains the information in minutes. Calculated by the function \code{calc_time_diff}
#' @param categories Character vector. Containing the intervals which should be used for the grouping mechanism. 
#' @examples Possible categories can be.
#' 15, 60 min, 60min> - <1440. Unit is minutes.
#' String to analyze intervals < 15 minutes, > 15 < 60 minutes and >60 minutes. Default: all categories will be analyzed
#' @param sort Logical. Should the returned output data be sorted for improved readability? Default: TRUE.
#' Only the output will be sorted. Predefined sort logics existing in \code{df} remain.
#' 
#' @return A named list of data frames. Each list element contains all records belonging to one predefined temporal interval category.
#'  \itemize{
#'    \item \code{above1440}: Contains the records which temporal gap of examined time steps exceed 1440 minutes (1 day).
#'    \item \code{between60_1440}: Contains the records which temporal gap is situated between 60 minutes and 1440 minutes.
#'    \item \code{between15_60}: Contains the records which temporal gap is situated between 15 minutes and 60 minutes.
#'    \item \code{below15}: Contains the records which temporal gap of examined time steps is below 15 minutes.
#'    
#' @author Kai Albert Zwießler
#' 
#' @seealso This functions is dependent on the execution of function \code{calc_time_diff} prior to execution, as it builds on the calculated results stored
#' in \code{timediff_col}. All functioned mentioned lay the groundwork for temporal gaps or temporal harmonization steps.
#' \code{\link{calc_time_diff}{Calculate time difference (in minutes) of each individual device and stores the results in a separate column.}
#' \code{\link{function_timediff_sum}} Allows to access a comprehensive tabular overview. - Works good in combination with \code{check_temporal_inconsistencies}
#' @export


check_temporal_inconsistencies <- function(
    df,
    date_col = "Date",
    id_col = NULL,
    timediff_col = NULL,
    categories = c("below15", "between15_60", "between60_1440", "above1440"),
    thresholds = c(15, 60, 1440),
    sort = TRUE
) {
  
  # Input validation
  # 1. Check if data frame has right type
  if (!is.data.frame(df)){
    stop("df must be a data.frame or tibble.")
  }
  
  # date column validation

  if (is.null(date_col)) {
    stop("`date_col` must be specified. ")
  }
  if (!date_col %in% names(df)) {
    stop("`date_col` must be a present in `df`. ")
  }
  
  #id col validation
  
  if (!is.null(id_col) && !id_col %in% names(df)) {
    stop("`id_col` must deliver a column name in the data frame. ")
  }    
  
  #time diff col validation
  if (is.null(timediff_col)) {
    stop("`timediff_col` must be specified. The columns needs to contain the calculated time differences from one time step to the following. ")
  }
  if (!timediff_col %in% names(df)) {
    stop("`timediff_col` must be present in `df`. If no `timediff_col` exists please check the functions notes and dependencies. ")
  }
  
  #categories validation
  allowed_categories <- c(
    "below15",
    "between15_60",
    "between60_1440",
    "above1440"
  )
  
  if (!all(categories %in% allowed_categories)) {
    stop(
      "Only the following categories are allowed: ",
      paste(allowed_categories, collapse = ", "),
      "."
    )
  }
  
  # converting strings into symbols dplyr logic.
  date_column <- rlang::sym(date_col)
  timediff_column <- rlang::sym(timediff_col)
  
  if (!is.null(id_col)){
    id_column <- rlang::sym(id_col)
  }
  
  
    # creating an empty list where the results will be stored.  
    interval_results <- list()
    
    # calculates & safes the time steps > daily time steps into a list
    if ("above1440" %in% categories) {
      interval_results$above1440 <- df %>%
        filter(!!timediff_column > 1440) %>%
        mutate(category = "above1440")  
    }
    
    # calculates the results in between 60 min and daily time step and safes it
    if ("between60_1440" %in% categories) {
      interval_results$between60_1440 <- df %>%
        filter(!!timediff_column < 1440, !!timediff_column > 60) %>%
        mutate(category = "between60_1440") 
    }  
    
    # calculates the results in between 60 min and daily time step and safes it
    if ("between15_60" %in% categories) {
      interval_results$between15_60 <- df %>%
        filter(!!timediff_column < 60, !!timediff_column > 15) %>%
        mutate(category = "between15_60")  
    }  
    
    # calculates the time steps below 15 minutes  and safes it into a list
    if ("below15" %in% categories){ 
      interval_results$below15 <- df %>% 
        filter(!!timediff_column < 15) %>%
        mutate(category = "below15")
    }
  
  #sorting mechanism
  if (sort) {
    
    interval_results <- lapply(interval_results, function(x) {
      
      if (is.null(id_col)) {
        x %>% arrange(!!date_column)
      } else {
        x %>% arrange(!!id_column, !!date_column)
      }
      
    })
    
  }
  
  return(interval_results)
}  