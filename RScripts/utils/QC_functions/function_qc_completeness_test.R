#======================================================================
# Script name: function_qc_completeness_test.R
# Function name: qc_completeness_test
# Goal(s): 
  # Check in the assigned measurement columns for at least one missing value
  # report to the operator via a list how many values were detected for each measurement variable absolute count and percent.
  # Also in the final report detection_summary are the values that have no missing values and are 100% complete for a comprehensive summary.
  # report the total amount of checked values, detected values and their percentage to the operator in the console.
# Author: 
# Date: 2026.07.07
#======================================================================

#' @title Quality control completeness test.
#' @description  Extracts and provides information if one value in the measurement columns is missing. Works for a master data frame or individual files. 
#' The function is intended for multi-sensor data sets where individual series are identified via a grouping column (e.g. Source.Code or ID).
#' But can also be applied on a single data frame without identifier.
#' @param df master data frame, data frame or tibble
#' @param date_column Character string. Column which contains the temporal information for the time series. Used for sort mechanism for final report in $data.
#' Default: "Date".
#' @param measurement_columns Character vector containing all columns where the measurement values are stored.
#' @param source_column Character string. Specifying the column that contains the values provided in `source_ids`.
#' @param source_ids Character vector defining the groups that should undergo the completeness test. 
#' Values usually represent file identifiers (f.e. Source.Code or Sensor ID).
#' Individual files of a master data frame can be selected by providing a character vector containing their source name or another clear identifier. 
#' Whole hydrological sensors or meteorological stations can be tested by providing a shared identification ID describing the whole sensor group.
#' @return list with a data frame and a report on how many values have been detected by the test. The data frame can then be used for further flagging workflows.
#'  \describe{
#'    \item{data}{Contains all records where at least one measurement column is NA.}
#'    \item{detection_summary}{Contains further information how many values for each measurement variable have been detected.
#'    \code{n_detected} is the total amount of detected values, and \code{pct_detected} is the percentage of the detected values in relation
#'    to the total values examined (both reported per measurement column, e.g. \code{n_detected_Abs_pres}, \code{pct_detected_Abs_pres}).}
#'  }
#' 
#' @references 
#' WMO, 2011. Guide to Climatological Practices (WMO-No. 100), Third Edition. ed.
#' pp. 9–11 (Chapter 3) 
#' World Meteorological Organization, Geneva, Switzerland.
#' 
#' @export
#' 
#' @author Kai Albert Zwießler
#' 
#' @seealso Workflow suggestion using the integrated functions:
#' \code{\link{function_apply_qc_flags}} to assign the respective QC flags using the generated data frame & 
#' \code{\link{function_log_qc_decisions}} for documentation of the results concerning data quality.


qc_completeness_test <- function(df,
                                 date_column = "Date",
                                 measurement_columns = NULL,
                                 source_column = NULL,
                                 source_ids = NULL){
  
  
  # --- Input validation
  if (!is.data.frame(df)) {
    stop("`df` must be a data.frame or tibble.")
  }
  # date column validation
  # date_column character & vector validation
  if (!is.character(date_column) || length(date_column) != 1) {
    stop(
      "`date_column` must be a single character string not a character vector."
    )
  }
  if (!date_column %in% names(df)) {
    stop(paste("`date_column`", date_column, "not found in `df`."))
  }
  
  # measurement_columns validation
  if (is.null(measurement_columns)) {
    stop(
      "Please specify the `measurement_columns` parameter according to the measurement columns used in the data frame. "
    )
  }
  if (!is.character(measurement_columns)) {
    stop(
      "The `measurement_columns` parameter must be a character vector. "
    )
  }
    # extract missing column names compared to the data frame.
    missing_measurement_columns <- measurement_columns[!measurement_columns %in% names(df)]
    if (length(missing_measurement_columns) > 0) {                                                   
    stop(
      paste0("The following `measurement_columns` were not found in `df`.: ",
             paste(missing_measurement_columns, collapse = ", "), "."
    ))
    }
  
  # source_column and source_ids
  
  if(!is.null(source_column) && is.null(source_ids)){
    stop("The `source_ids` parameter must be specified if `source_column` is provided. Please specify the ID-code for individual data files or sensor groups. ")
  }
    if(is.null(source_column) && !is.null(source_ids)){
    stop("The `source_column` parameter must be specified if `source_ids` are provided. Please specify the column in which the `source_ids` information can be found.")
  }
  if (!is.null(source_column) && !is.character(source_column)) {
    stop("`source_column` must be a character string or NULL.")
  }
  if (!is.null(source_ids) && !is.character(source_ids)) {
    stop("`source_ids` must be a character string or character vector.")
  }
  if (!is.null(source_column) && length(source_column) != 1) {
    stop("`source_column` must be a single character string. No character vector. ")
  }
  if (!is.null(source_column) && !source_column %in% names(df)) {
    stop(paste0("`source_column` '", source_column, "' not found in `df`."))
  }
  # Check if source_ids values exist in source_column
  if(!is.null(source_ids)){
    missing_source_ids <- source_ids[!source_ids %in% df[[source_column]]]
      if (length(missing_source_ids) > 0) {
        stop(paste0(
          "The following `source_ids` values were not found in provided source_column. '", source_column, "': ",
          paste(missing_source_ids, collapse = ", "), "."
        ))
      }
    }
  if (is.null(source_column) && is.null(source_ids)) {
    message("The completeness test will be performed on the whole data frame without a grouping mechanism. \n",
            "If you run this function on a master data frame in a pipeline setting it is highly suggested to use a grouping mechanism by providing `source_ids` \n",
            "and `source_column` \n",
            "`source_column` defines the grouping column and `source_ids` define either individual files or whole sensor-groups that ", 
            "should undergo the completeness test workflow. "
    )
  }
  # condition for the master data frame workflow
  if(!is.null(source_column) && !is.null(source_ids)){
  # filter the required source_ids
  filtered_df <- df |> 
    filter(.data[[source_column]] %in% source_ids)
  
  # Determine all NA's in the filtered data frame
  rows_with_NA <- filtered_df |> 
    filter(
      if_any(
        all_of(measurement_columns),
        is.na
      )
    ) |> 
    arrange(.data[[source_column]], .data[[date_column]])
  
  # Statistic of detected values
  detection_summary <- filtered_df |> 
    group_by(.data[[source_column]]) |>
      summarise(
        n_group = n(),
        n_group_detected = sum(
          if_any(
            all_of(measurement_columns), is.na)),
        percent_detected = round(n_group_detected / n_group * 100, digits = 2),
        across(
          all_of(
          measurement_columns), .fns = list(
            n_detected = ~ sum(is.na(.x)),
            pct_detected = ~ round(sum(is.na(.x)) / length(.x) * 100, digits = 2)), 
          .names = "{.fn}_{.col}" # {.fn} is defined in the names in the function list
          )
        ) |> 
      ungroup()
  
  # General statistic derivation for message output
  total_values <- nrow(filtered_df)
  total_detected_output <- nrow(rows_with_NA)
  total_percentage <- round(total_detected_output / total_values * 100, digits = 2)
  
  message(
    paste0(
      "Completeness Test has been executed successfully ✓.\n",
      "In total '", total_values, "' values have been examined.\n",
      "From which '", total_detected_output, "' failed the test.\n",
      "This makes a total percentage of '", total_percentage, "'%.\n\n", 
      "Check detection_summary in the generated list inside the global environment ",
      "for a detailed description for each measurement value.\n\n", 
      "The $data point inside this list shows all rows where at least one ",
      "measurement value was NA."
    )
  )
  
  return(list(
    data = rows_with_NA,
    detection_summary = detection_summary
  ))
  
  }else {
    rows_with_NA <- df |> 
      filter(
        if_any(
          all_of(measurement_columns),
          is.na
        )
      ) |> 
      arrange(.data[[date_column]])
  
  detection_summary <- df |> 
    summarise(
      n_total = n(),
      n_detected = sum(
        if_any(
          all_of(measurement_columns), is.na)),
      percent_detected = round(n_detected / n_total * 100, digits = 2),
      across(
        all_of(
          measurement_columns), .fns = list(
            n_detected = ~ sum(is.na(.x)),
            pct_detected = ~ round(sum(is.na(.x)) / length(.x) * 100, digits = 2)), 
        .names = "{.fn}_{.col}"
      )
    ) |> 
    ungroup()
  
  
  
  # General statistic derivation for message output
  total_values <- nrow(df)
  total_detected_output <- nrow(rows_with_NA)
  total_percentage <- round(total_detected_output / total_values * 100, digits = 2)
  
  message(
    paste0(
  "Completeness Test has been executed successfully ✓.\n",
  "In total '", total_values ,"' values have been examined.\n",
  "From which '",total_detected_output, "' failed the test.\n",
  "This makes a total percentage of '",total_percentage, "'%.\n\n", 
  "Check detection_summary in the generated list inside the global environment for a detailed description for each measurement value. ")
  )
  
  
  warning(
    paste0(
      "The Completeness Test has been executed successfully on the whole data frame.\n",
      "If you use a master data frame as input which contains different sensors, separated with a unique identifier\n",
      "You want to use source_column and source_ids for specification.\n",
      "Please check the returned data and detection_summary in the global environment. ")
  )
      
  
  return(list(
    data = rows_with_NA,
    detection_summary = detection_summary
  ))
  } 
}