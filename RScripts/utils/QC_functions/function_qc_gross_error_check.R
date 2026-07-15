#======================================================================
# Script name: function_qc_gross_error_check.R
# Function name: qc_gross_error_check
# Date: 2026.07.12
#======================================================================

#' @title Quality control - WMO's Gross Error Check.
#' 
#' @description  Checks if a value of a certain measurement value is out of predefined thresholds. If that's the case the whole row
#' is extracted and stored in a separate data frame under the following reference \code{$data}.
#' This can be used as input for the flagging workflow with function \code{apply_qc_flags}. 
#' Additionally, the function generates a \code{$detection_summary} report containing the total amount of tested rows, the number and percentage flagged,
#' and the same statistic for each variable.
#'
#' @details 
#' The function is able to process multi-sensor data sets where individual files or whole sensor groups are identified via a grouping column (e.g. Source.Code or ID).
#' The function can also be applied on a single data frame without identifier by not providing \code{source_column} and \code{source_ids}. 
#' 
#' The test is designed for fixed threshold values which are important for shorter time frames.
#' Therefore, it differs from a climatological test using IQR for threshold ranges.
#' 
#' @note  the \code{thresholds} parameter is a named list and to maintain its structure is mandatory. 
#' The names have to match exactly the column names in \code{df}. Additionally, each element must be a numeric vector of length two with names "lower" and "upper".
#' 
#' The function ignores NA values in the statistical calculations! Neither in the reported \code{$detection_summary} nor in the \code{$data} part of the list will occur
#' rows where all measurement columns are NA.
#' NA values are treated separate by \code{\link{qc_completeness_test}}.
#' 
#' If no \code{source_column} or \code{source_ids} are provided the function is applied to the whole \code{df}.
#' This is implemented for case the operator only has one station or one file.
#' 
#' @param df master data frame, data frame or tibble
#' @param date_column Character string. Column which contains the temporal information for the time series. Used for sort mechanism for final report in $data.
#' Default: "Date".
#' @param thresholds Named list. Containing the names of each measurement variable, has to match exactly the column name of the respective variable in \code{df}
#' and each element must be a numeric vector of length two with names lower and upper.
#' See the example provided at the end of the roxygen documentation on how to structure the input for this variable.
#' @param source_column Character string. Specifying the column that contains the values provided in `source_ids`.
#' "source_column" and "source_ids" are interdependent.
#' @param source_ids Character vector defining the groups that should undergo the test. 
#' Values usually represent file identifiers (f.e. Source.Code or Sensor ID).
#' Individual files of a master data frame can be selected by providing a character vector containing their source name or another clear identifier. 
#' Whole hydrological sensors or meteorological stations can be tested by providing a shared identification ID describing the whole sensor group.
#' 
#' @return list with a data frame and a report on how many values have been detected by the test. The generated data frame can then be used for further flagging workflows.
#'  \describe{
#'    \item{data}{Contains all records where at least one measurement variable did not pass the test.}
#'    \item{detection_summary}{Contains further information how many values for each measurement variable have been detected.
#'    On a group level (or for the entire data frame if no \code{source_column}/\code{source_ids} are provided), \code{n_group}/\code{n_total} report 
#'    the total number of tested rows, \code{n_group_detected}/\code{n_detected_total} the number of rows with at least one detected value, and 
#'    \code{pct_group_detected}/\code{pct_detected_total} the respective percentage. On a per-variable level, \code{n_detected} is the total amount 
#'    of detected values, and \code{pct_detected} is the percentage of the detected values in relation to the total values examined. Both metrics are 
#'    reported for each measurement column individually, e.g. \code{n_detected_Abs_pres}, \code{pct_detected_Abs_pres}. In all statistics, rows or 
#'    values where the respective measurement column(s) are NA are excluded.}
#'  }
#'  
#' @references
#' Written by: Zahumenský, Igor, 2004. - Guidelines on Quality Control Procedures for Data from Automatic Weather Stations,
#' Slovak Hydrometeorological Institute, Slovakia. 
#' Originally published in: 
#' WMO, 1993: WMO Guide on Global Data Processing System (WMO-No. 305).
#' Chapter 6 - Quality Control Procedures.
#' World Meteorological Organization, Geneva, No. 305,
#' VI.1-VI.27, ISBN 92-63-13305-0 
#' 978-92-63-13305-2.
#' 
#' @export
#' 
#' @author Kai Albert Zwießler
#' @seealso Documentation Workflow suggestion using the generated test result with other functions:
#' \code{\link{apply_qc_flags}} to assign the respective QC flags using the generated \code{$data} &
#' \code{\link{log_qc_decisions}} to generate a log file containing valuable information about the process and framework conditions.
#' @examples Example on how to structure the named list for the \code{thresholds} parameter.
#' \dontrun{
#' my_thresholds <- list(
#'   AirTC = c(lower = -20, upper = 50),
#'   RH    = c(lower = 0,   upper = 100)
#' )
#' qc_gross_error_check(df = my_data, thresholds = my_thresholds)}



qc_gross_error_check <- function(df,
                                 date_column = "Date",
                                 thresholds = NULL,
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
  
  # thresholds validation
  if (is.null(thresholds)) {
    stop(
      "The threshold parameter must be a numeric list. Please specify the `thresholds` parameter according to the following scheme\n",
      "{Exact name of the column of the measurement variable in `df` = c(threshold lower, threshold upper)} e.g\n",
      "AirTC = c(lower = -20, upper = 50), RH = c(lower = 0, upper = 100), (...). "
    )
  }
  if (!is.list(thresholds)) {
    stop(
      "The `thresholds` parameter must be a list. "
    )
  }
  
  if(is.null(names(thresholds))){
    stop(
      "The `thresholds` parameter must be a named list. "
    )
  }
  
  if (!purrr::every(thresholds, ~ is.numeric(.x) && length(.x) == 2)) { # every checks if every element of that list full fills the condition.
    # every contains two functions elements that both have to be full filled to pass the validation test.
    stop(
      "The values inside the `thresholds` parameter list must be of type numeric and length two."
    ) 
  }
  
  #extract missing column names in the configuration list
  missing_names_measurement_columns <- names(thresholds)[!names(thresholds) %in% names(df)] # extraction of the names inside thresholds which are not inside df.
    # "!" used to extract the missing ones. names(thresholds)[] used to extract specifically the names of the result instead of a TRUE/FALSE logical vector.
    if (length(missing_names_measurement_columns) > 0) {                                                   
      stop(
        paste0("The following names of measurement variables, specified in the `thresholds` parameter do not match the names of the columns in `df`\n",
        "for the respective measurement variables.: ",
               paste(missing_names_measurement_columns, collapse = ", "), "."
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
    message("The gross error check will be performed on the whole data frame without a grouping mechanism. \n",
            "If you run this function on a master data frame in a pipeline setting please use a grouping mechanism by providing `source_ids` \n",
            "and `source_column` \n",
            "`source_column` defines the grouping column and `source_ids` define either individual files or whole sensor-groups that ", 
            "should undergo the gross error check. "
    )
  }


  # filter condition for the master data frame workflow
  if(!is.null(source_column) && !is.null(source_ids)){
    # filter the required source_ids
    filtered_df <- df |> 
      filter(.data[[source_column]] %in% source_ids)
    
    # generating detected df containing the intermediate result for $data and $detection summary 
    detected_df <- filtered_df |> 
      mutate( # uses the output of the across() function to generate a column for each variable in names(thresholds). The name is provided by .names.
        across(
          .cols = names(thresholds), 
          .fns = ~ .x < unname(thresholds[[cur_column()]]["lower"]) | # >< provides a logical vector TRUE/FALSE
                   .x > unname(thresholds[[cur_column()]]["upper"]),  # cur_column provides the names, with [[]] the variable is sufficiently indexed
          # to enter the stored element of the name. The next indexing step provides the selected threshold upper or lower. But together with its name. 
          # Thats why unname() is required additionally.
          .names = "{.col}_out_of_range" # out_of_range construction is picked up in the filter step!
          )
      )
     
    detected_records <- detected_df|>
      filter(
        if_any(
          .cols = ends_with("_out_of_range"), # Column selection scheme using the end of the column names defined in .names above to select the columns
          # containing the detection information generated from the detected_df pipeline.
          .fns = ~ !is.na(.x) & .x
        )
      ) |>
      arrange(.data[[source_column]], .data[[date_column]])
    
   
    detection_summary <- detected_df |> 
      group_by(.data[[source_column]]) |> 
        summarise( # workflow numbers for each group (row-based)
          n_group            = sum(
                                !if_all(ends_with("_out_of_range"), is.na)), # Answers the question: How many rows exist in that group, without the rows where every
    #measurement variable is NA. if_all is used as the condition when all are NA. ! to exclude them.
          n_group_detected   = sum(
                                if_any(ends_with("_out_of_range"), .fns = ~ !is.na(.x) & .x)), #How many rows have at least one value that did not pass the test.
          pct_group_detected = round(n_group_detected / n_group * 100, digits = 2 ),
          
            across( # worflow for group + each variable documentation
              .cols = ends_with("_out_of_range"),
              .fns = list(
                n_detected       = ~ sum(.x, na.rm = TRUE), # sum for all records inside a certain group.
                pct_detected     = ~ round(sum(.x, na.rm = TRUE) / sum(!is.na(.x)) * 100, digits = 2)), # this does not work. length and sum will produce the exact same values as all of them are already detected.
              .names = "{.fn}_{.col}"
            )
        )|> 
      rename_with(~ str_remove(.x, "_out_of_range"), .cols = contains("out_of_range")) |>
      ungroup()
    
    # General summary for console message excluding NA
    total_values <- sum(detection_summary$n_group)
    total_detected_output <- sum(detection_summary$n_group_detected)
    total_percentage <- round(total_detected_output / total_values * 100, digits = 2)
    
    message(
      paste0(
        "WMO's Gross Error Check has been executed successfully ✓.\n",
        "In total '", total_values, "' values have been examined.\n",
        "From which '", total_detected_output, "' failed the test.\n",
        "This makes a total percentage of '", total_percentage, "'%.\n\n", 
        "Check detection_summary in the generated list inside the global environment ",
        "for a detailed description for each measurement value.\n\n", 
        "The $data point inside this list shows all rows where at least one ",
        "measurement value has failed the test."
      )
    )
    
    return(list(
      data = detected_records,
      detection_summary = detection_summary
    ))
        
    
    }else {
      
      # generating detected df containing the intermediate result which will be used to generate $data and $detection summary 
      detected_df <- df |> 
    mutate( # uses the output of the across() function to generate a column for each variable in names(thresholds). The name is provided by .names.
      across(
        .cols = names(thresholds), 
        .fns = ~ .x < unname(thresholds[[cur_column()]]["lower"]) | # >< provides a logical vector TRUE/FALSE
          .x > unname(thresholds[[cur_column()]]["upper"]),  # cur_column provides the names, with [[]] the variable is sufficiently indexed
        # to enter the stored element of the name. The next indexing step provides the selected threshold upper or lower. But together with its name. 
        # Thats why unname() is required additionally.
        .names = "{.col}_out_of_range" # out_of_range construction is picked up in the filter step!
      )
    )
  
      # filtering the results, determining detected records
      detected_records <- detected_df|>
        filter(
          if_any(
            .cols = ends_with("_out_of_range"), # Column selection scheme using the end of the column names defined in .names above to select the columns
            # containing the detection information generated from the detected_df pipeline.
            .fns = ~ !is.na(.x) & .x
          )
        ) |>
        arrange(.data[[date_column]]) # arrange only by date since source column is not provided.
      
      # generating detection_summary for the output list
      detection_summary <- detected_df |> 
        summarise( # workflow numbers for each group (row-based)
          n_total            = sum(
            !if_all(ends_with("_out_of_range"), is.na)), # Answers the question: How many rows exist in that group, without the rows where every
          #measurement variable is NA. if_all is used as the condition when all are NA. ! to exclude them.
          n_detected_total   = sum(
            if_any(ends_with("_out_of_range"), .fns = ~ !is.na(.x) & .x)), #How many rows have at least one value that did not pass the test.
          pct_detected_total = round(n_detected_total / n_total * 100, digits = 2 ),
          across( # worflow for group + each variable documentation
            .cols = ends_with("_out_of_range"),
            .fns = list(
              n_detected       = ~ sum(.x, na.rm = TRUE), # sum for all records inside a certain group.
              pct_detected     = ~ round(sum(.x, na.rm = TRUE) / sum(!is.na(.x)) * 100, digits = 2)), # this does not work. length and sum will produce the exact same values as all of them are already detected.
            .names = "{.fn}_{.col}"
          )
        )|>
        rename_with(~ str_remove(.x, "_out_of_range"), .cols = contains("out_of_range")) |>
        ungroup()
     
       message(
        paste0(
          "WMO's Gross Error Check has been executed successfully .\n",
          "In total '", detection_summary$n_total, "' values have been examined.\n",
          "From which '", detection_summary$n_detected_total, "' failed the test.\n",
          "This makes a total percentage of '", detection_summary$pct_detected_total, "'%.\n\n", 
          "Check detection_summary in the generated list inside the global environment ",
          "for a detailed description for each measurement value.\n\n", 
          "The $data point inside this list shows all rows where at least one ",
          "measurement value has failed the test."
        )
      )
      
      return(list(
        data = detected_records,
        detection_summary = detection_summary
      ))
    }
}