#======================================================================
# Script name: function_persistence_test.R
# Function name: qc_persistence_test()
# Date: 2026.07.19
#======================================================================

#' @title Extended Persistence Test - Quality control for hydrometeorological time series
#' 
#' @description 
#' Robust persistence test approach taking into consideration two test metrics to detect frozen sensor's - using the range (max - min) approach 
#' and the standard deviation to detect long term sensor drift.
#' 
#' Two layer test design controlled by \code{metric} parameter:
#' 1. The range of a sliding temporal window is calculated and compared to a threshold value.
#' 2. Checks if the standard deviation, calculated from a flexible moving time window of previous time steps, is lower than an user-defined threshold value.
#' In both scenarios Values are flagged if they do not manage to exceed the threshold value.
#'
#' @details 
#' The function is able to process multi-sensor data sets where individual files or whole sensor groups are identified via a grouping column (e.g. Source.Code or ID).
#' The function can also be applied on a single data frame without identifier by not providing \code{source_column} and \code{source_ids}.
#' 
#' The sliding \code{window} has to fully form before any outputs are generated or \code{min_coverage} is tested.
#' 
#' The function uses a sliding window with a customizable length.
#' Available test metrics is the range (| max - min |) and standard deviation.
#' 
#' When a new temporal window some values can not be tested. Therefore, they will be reported in \code{$coverage_problems} for manual workflows
#' 
#' @note 
#' 
#' 
#' 
#' The operator has to be aware of the selected test \code{metric}, as the nomenclature in the final report \code{$detection_summary} is equal
#' for both \code{metric} options.
#' 
#' The user must be aware of the set thresholds in relation to the measured variable, environmental circumstances, location and examined time steps. (WMO, 2011)
#' 
#' Information to correctly interpret the percentage of detected values calculated in the final report for each variable:
#'  1. \code{pct_detected_<var>} takes into consideration all rows inside a group. Rows that have not been tested due to \code{min_coverage} are also included.
#'  2. This leads to a small underestimation of the percentage of detected values if many \code{coverage_problems} exist.
#'  3. The direction of this systematic BIAS is a underestimation of the percentage of detected values for each variable.
#'  4. To access the specific amount for each variable check \code{coverage_problems}.
#' 
#' the \code{thresholds} parameter is a named list and to maintain its structure is mandatory. 
#' The names have to match exactly the column names of the tested variables in \code{df}. 
#' Additionally, each element must be a numeric.
#' 
#' Because the comparison happens between a whole number of available values and a decimal threshold, non-integer results of \code{min_coverage} * \code{window} 
#' are effectively rounded up: 
#' @examples
#' \dontrun{
#' at \code{window} = 3, \code{min_coverage} = 0.5, the required threshold is 1.5, which only whole-number counts of 2 or more satisfy.
#' 
#' The test is failed if the calculated  \code{metric} < \code{thresholds}. If the exact same value is calculated than defined in \code{thresholds}
#' the test is passed.
#' 
#' The operator decides according to the threshold set in \code{min_coverage} how many values inside the sliding window are required
#' to maintain robust test results.
#' 
#' The function can be applied on a single file or station or on a master data frame containing multiple sensors separated with an identifier.
#' If no \code{source_column} and \code{source_ids} are specified the function is applied to the whole \code{df}. Please note that this can lead to
#' undesired test results when applied on a master data frame.
#' If a master data frame is used \code{source_column} and \code{source_ids} need to be specified.
#' 
#' The test can be executed if the time series contains NA values. They will considered in terms of decision-making. NA handling is executed as following:
#' 
#' 1. If the \code{min_coverage} condition is met but the value in question (last in the slider window) is \code{NA} the function returns \code{NA}.
#' 2. If a sequence of \code{NA} values are present the sliding windows starts to form when actual measurement values are present. The values that have not been tested
#' during the reformation of the window will be reported in \code{coverage_problems}.
#' 
#' The same row can appear in \code{$data} and \code{coverage_problems}. This is not an error but a possible test outcome. As the test is variable-based,
#' a coverage problem can occur for one variable while the other has exceeded the \code{min_coverage} threshold and therefore contains a sufficient number 
#' of values to calculate a robust test result.
#' 
#' @param df master data frame, data frame or tibble
#' @param date_column Character string. Column which contains the temporal information for the time series. Used for sort mechanism for final report in $data.
#' @param metric Character vector. Two options either "range" or "sd" to select the desired statistical metric which will be used to calculate the results for
#' threshold comparison.
#' @param thresholds Named list containing named numeric vectors. Containing the names of each measurement variable, has to match exactly the column name of the 
#' respective measurement variable in \code{df} and each element must be a numeric vector.
#' See the example provided at the end of the roxygen documentation on how to structure the input for this variable.
#' @param window numeric string. A number that determines the total amount of examined values of the sliding window. Previous time steps + the present time step.
#' @param min_coverage A single numeric value between 0 and 1 defining the minimum required values inside the sliding temporal window where
#' robust statistical results can be calculated and a robust distinction of a test detection is representative.
#' Sliding \code{window}'s who do not meet required numbers of values, set by the \code{min_coverage} threshold are reported separately to the operator.
#' @examples
#' \dontrun{
#' Example for 15-minute time steps: One hour contains 4 values = Window = 4. Therefore, a \code{min_coverage} value of 0.5 requires at least 2 valid values 
#' inside the sliding window.
#' For calculated result between \code{window} and \code{min_coverage} who are a decimal figure, a conservative rounding takes place. 
#' \code{window} = 3, \code{min_coverage} = 0.5 the functions rounds to → 2 of 3 required values, not 1.5.}
#' 
#' @param source_column Character string. Specifying the column that contains the values provided in `source_ids`.
#' "source_column" and "source_ids" are interdependent.
#' @param source_ids Character string or vector defining the groups that should undergo the test. 
#' Values usually represent file identifiers (f.e. Source.Code or Sensor ID).
#' Individual files of a master data frame can be selected by providing a character vector containing their source name or another clear identifier. 
#' Whole hydrological sensors or meteorological stations can be tested by providing a shared identification ID describing the whole sensor group.
#' 
#' @return list with a data frame and a report on how many values have been detected by the test. The generated data frame can then be used for further flagging workflows.
#'  \describe{
#'    \item{data}{Contains all records where at least one measurement variable did not pass the test. The variable that did not pass the test
#'    is marked as \code{TRUE} in the test outcome column (_CVE)}
#'    \item{detection_summary}{Contains further information how many values for each measurement variable have been detected.
#'    On a group level (if \code{source_column} & \code{source_ids} are provided) or for the entire data frame (if not), \code{n_total_tested} reports the total 
#'    number of tested values across all measurement variables ignoring \code{NA}, 
#'    \code{n_total_detected} the total number of values that did not pass the test., 
#'    \code{pct_total_detected} the respective percentage out of the previous two. (Detected values compared to the total number of examined values). 
#'    These three column names are used identically in both scenarios (grouped and single data frame).
#'    On a per-variable level, \code{n_group_<var>} reflects the total number of values of the respective variable.
#'    \code{n_detected_<var>} is the total amount of detected values for the respective variable, and \code{pct_detected<var>} is the percentage of the 
#'    detected values in relation to the total number of values examined. Both metrics are reported for each measurement column individually, 
#'    (e.g. \code{n_detected_Abs_pres}, \code{pct_detected_Abs_pres}). 
#'    In all statistics, rows or values where the respective measurement column(s) are \code{NA} are excluded.} 
#'    Values that violated the min_coverage condition are included in the total, see \code{note} for the resulting reporting-BIAS. 
#'    }
#'    \item{coverage_problems}{Contains the rows where at least one variable could not be tested because the threshold dictated by \code{min_coverage}
#'    was not met to achieve a a robust test result and if the sliding windows has not formed fully.
#'    The variable causing the threshold violation can be identified as it is marked as TRUE in the column \code{<var>_coverage_problem}.
#'    Scenarios where values will be stored in \code{Coverage_problems} are for example at the start of each data set when the sliding window is formed.
#'    A second scenario is described when the sensor is disconnected from the logger (maintenance or data collection events) 
#'    and a series of NA values are produced. After that series when new measurement values are recorded a new formation of the sliding window takes place.}
#'  }
#'  
#' @references Approach for the two test statistics and sliding time window. Threshold values for the range version are adopted here.
#' Zahumenský, Igor, 2004. - Guidelines on Quality Control Procedures for Data from Automatic Weather Stations,
#' Chapter 2 - BASIC QUALITY CONTROL PROCEDURES b) Page 5 - 6.
#' Slovak Hydrometeorological Institute, Slovakia. 
#' Originally published in: 
#' WMO, 1993: WMO Guide on Global Data Processing System (WMO-No. 305).
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
#'   Abs_pres   = c(range = 0.2, sd = 0.2),
#'   Temp       = c(range = 1, sd = 1)
#' qc_persistence_test(df = my_data, thresholds = my_thresholds)}


qc_persistence_test <- function(df, 
                                date_column = NULL, 
                                metric = c("range", "sd"), 
                                thresholds = NULL, 
                                window = NULL, 
                                min_coverage = NULL, 
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
  
  # metric validation
  if (!is.character(metric) && length(metric) != 1) {
    stop(
      "The `metric` parameter must be a single character string."
    )
  }
  # spelling and selection check, using match.arg
  metric <- match.arg(metric, choices = c("range", "sd"))
  
  # thresholds validation
  if (is.null(thresholds)) {
    stop(
      "The threshold parameter must be provided with a named, numeric list. Please specify the `thresholds` parameter according to the following scheme\n",
      "{Exact name of the column of the measurement variable in `df` = c(range = threshold value, sd = threshold value)} e.g\n",
      "AirTC = c(range = 1, sd = 0.1), RH = c(range = 1, sd = 0.1), (...). "
    )
  }
  if (!is.list(thresholds)) {
    stop(
      "The `thresholds` parameter must be inside a list. "
    )
  }
  
  if(is.null(names(thresholds))){
    stop(
      "The `thresholds` parameter must be a named list. "
    )
  }
  
    if (!purrr::every(thresholds, ~ setequal(names(.x), c("sd", "range")))) { # setequal functions allows to validate the names of the named
    # character vector despite their order inside the configuration.
    stop(
      "The names inside the `thresholds` parameter for the named vector must be either `range` or `sd`."
    ) 
  }
  
  
  if (!purrr::every(thresholds, ~ is.numeric(.x) && length(.x) == 2)) { # every checks if every element of that list full-fills the condition.
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
  
  # extract which measurement variables are missing the threshold value that matches the selected metric
  missing_metric_thresholds <- names(thresholds)[!purrr::map_lgl(thresholds, ~ metric %in% names(.x))]
  # map_lgl applies the check to every element and returns one TRUE/FALSE per element (keeping thresholds' names),
  # names(thresholds)[!...] then extracts the specific variable names where the check was FALSE.
  
  if (length(missing_metric_thresholds) > 0) {
    stop(paste0(
      "The selected `metric` ('", metric, "') has no matching threshold value for the following measurement variable(s): ",
      paste(missing_metric_thresholds, collapse = ", "), ".\n",
      "Each element in `thresholds` must contain a value named '", metric, "' to use this metric."
    ))
  }
  
  
  
  #window validation
  
  if (!is.numeric(window) || length(window) != 1) {
    stop(
      "`window` must be a single numeric string not a numeric vector."
    )
  }
  if (!(window %% 1 == 0) || window <= 0) { # %% Modulo operator. No allowed rest when divided by 1
    stop(
      "`window` must be a positive whole number (integer values only, no decimals)."
    )
  }
  
  # min_coverage validation
  if (is.null(min_coverage)){
    stop("`min_coverage` needs to be specified. The statistical tests executed in this function need at least two measurement values to generate robust results.")
  }
  if (!is.numeric(min_coverage) || length(min_coverage) != 1) {
    stop("`min_coverage` must be single numeric value between 0 and 1.")
  }
  if (min_coverage <= 0 || min_coverage > 1) {
    stop("`min_coverage` must be  > 0 and <= 1.")
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
  
  # filter condition for the master data frame workflow
  if(!is.null(source_column) && !is.null(source_ids)){
    # filter the required source_ids
    filtered_df <- df |> 
      filter(.data[[source_column]] %in% source_ids) |> 
    # preparing the use of slider package with group_by mechanism and arranged date column
      group_by(.data[[source_column]]) |>
        arrange(.data[[source_column]], .data[[date_column]])
  
    
    #coverage test
    coverage_problem_detected <- filtered_df |> # data frame containing the evaluated min coverage results.
      mutate( # uses the output of the across() function to generate a column for each variable in names(thresholds). The name is provided by .names.
        across(
         .cols = names(thresholds),
         .fns = ~ slider::slide_lgl( # slide_dbl function as the function argument for across to run for every measurement variable
            .x = .x, # .x the vector from the across command. means the current variable.
            # "." convention as placeholder to separate the operational area of across and slider_dbl placeholder
            .f = ~ sum(!is.na(.)) < (min_coverage * window) | (length(.) < window), # . as we still operate inside the sliding window. How many values are inside the sliding window.
            .before = window - 1, # -1 as slider counts the present examined value, as well as the previous ones.
            .after = 0),
         .names = "{.col}_coverage_problem"
        )
      )
            
         
    if(metric == "range") { # min_coverage rows not filtered beforehand. this would alter calculation of the sliding window. and is against the nature of the
      #persistence test.
      marked_detections_df <- coverage_problem_detected |>
        mutate( # uses the output of the across() function to generate a column for each variable in names(thresholds). The name is provided by .names.
          across(
            .cols = names(thresholds),
            .fns = ~ slider::slide_lgl( # slide_dbl function as the function argument for across to run for every measurement variable
              .x = .x, # .x the vector from the across command. means the current variable.
              # "." convention as placeholder to separate the operational area of across and slider_dbl placeholder
              .f = ~ if(is.na(dplyr::last(.)) || sum(!is.na(.)) < (min_coverage * window)) { # NA check before the statistical metric is calculated. For the case 
                #no coverage_problem, value in question (last value) = NA.
                NA
              }else { # range case
                max(., na.rm = TRUE) - min(., na.rm = TRUE) < unname(thresholds[[dplyr::cur_column()]]["range"]) # cur_column get the name of the variable 
                #currently processed
                #accessing the range threshold for comparison. # unname as only the value is required not range = X.
                # . as we still operate inside the sliding window. How many values are inside the sliding window.
                }, 
              .before = window - 1, # -1 as slider counts the present examined value, as well as the previous ones. 
              .after = 0,
              .complete = TRUE),
            .names = "{.col}_CVE"
          )
        )
    
    } else{
      marked_detections_df <- coverage_problem_detected |>
        mutate( # uses the output of the across() function to generate a column for each variable in names(thresholds). The name is provided by .names.
          across(
            .cols = names(thresholds),
            .fns = ~ slider::slide_lgl(
              .x = .x, 
              .f = ~ if(is.na(dplyr::last(.)) || sum(!is.na(.)) < (min_coverage * window)) { # NA check before the statistical metric is calculated. For the case 
                # no coverage_problem, value in question = NA.
                NA 
              }else {
                sd(., na.rm = TRUE) < unname(thresholds[[dplyr::cur_column()]]["sd"]) 
                }, 
              .before = window - 1, 
              .after = 0,
              .complete = TRUE),
            .names = "{.col}_CVE"
          )
        )
      
    }
    
    # Reporting section for both options range and sd within source_ids workflow
    
    # coverage problems filter
    coverage_problems <- marked_detections_df |>
      filter(
        if_any(
          .cols = ends_with("_coverage_problem"), # Column selection scheme using the end of the column names defined in .names above to select the columns
          # containing the detection information generated from the marked_detections_df pipeline.
          .fns = ~ !is.na(.x) & .x, #Report all rows that have not fulfilled the coverage conditions
        )
      ) |>
      arrange(.data[[source_column]], .data[[date_column]])
    
    # $data filter
    detected_records <- marked_detections_df|>
      filter(
        if_any(
          .cols = ends_with("_CVE"), # Column selection scheme using the end of the column names defined in .names above to select the columns
          # containing the detection information generated from the marked_detections_df pipeline.
          .fns = ~ !is.na(.x) & .x # Stores the values in detected_records
          # that are detected by the test (TRUE) and not NA.
        )
      ) |>
      arrange(.data[[source_column]], .data[[date_column]])
    
    #detection summary reporting detected results excluding the values who failed min_coverage.
    detection_summary <- marked_detections_df |> 
      group_by(.data[[source_column]]) |> 
      summarise( # summarise always summarises the row-based results and expresses them in a number.
        n_total_tested     = sum(!is.na(c_across(ends_with("_CVE")))), #c_across to aggregate the statistics over multiple columns here all that end with CVE.
        n_total_detected   = sum(c_across(ends_with("_CVE")), na.rm = TRUE), # na.rm ignores NA to achieve a calculation result.
        pct_total_detected = round(n_total_detected / n_total_tested * 100, digits = 2),
        
        across( #Entering variable specific reporting workflow using across()
          .cols = ends_with("_CVE"),
          .fns = list(
            n_group          = ~ sum(!is.na(.x)),
            n_detected       = ~ sum(.x, na.rm = TRUE), # sum for all records inside a certain group that are TRUE (detected)
            pct_detected     = ~ round(n_detected / n_group * 100, digits = 2)),
          .names = "{.fn}_{.col}"
        )
      ) |> 
      rename_with(~ stringr::str_remove(.x, "_CVE"), .cols = contains("CVE")) |> # remove the _CVE content from the column names
      ungroup()
   
    message(
      paste0(
        "Persistence test has been executed successfully ✓.\n",
        "In total '", detection_summary$n_total_tested, "' values have been examined.\n",
        "From which '", detection_summary$n_total_detected, "' values failed the test.\n",
        "This makes a total percentage of '", detection_summary$pct_total_detected, "'%.\n\n", 
        "Check detection_summary in the generated list inside the global environment ",
        "for a detailed description for each measurement value.\n\n", 
        "The $data point inside this list shows all rows where at least one\n ",
        "measurement value has failed the test.\n",
        "$coverage_problems shows the values which have not been tested as they\n",
        "did not exceed the minimum amount of required values."
      )
    )
    
    return(list(
      data = detected_records,
      detection_summary = detection_summary,
      coverage_problems = coverage_problems
    ))
    
    
    
    
    
    
    }else{
    
    if (is.null(source_column) && is.null(source_ids)) {
      message("The persistence test will be performed on the whole data frame without a grouping mechanism. \n",
              "If you run this function on a master data frame in a pipeline setting please use a grouping mechanism by specifying `source_ids` \n",
              "and `source_column` \n",
              "`source_column` defines the grouping column and `source_ids` define either individual files or whole sensor-groups that ", 
              "should undergo the persistence test. "
      )
    }
    # df preparation for single df workflow
    arranged_df <- df |> 
      arrange(.data[[date_column]])
    
    
    coverage_problem_detected <- arranged_df |> # data frame containing the evaluated min coverage results.
      mutate( # uses the output of the across() function to generate a column for each variable in names(thresholds). The name is provided by .names.
        across(
          .cols = names(thresholds),
          .fns = ~ slider::slide_lgl( # slide_dbl function as the function argument for across to run for every measurement variable
            .x = .x, # .x the vector from the across command. means the current variable.
            # "." convention as placeholder to separate the operational area of across and slider_dbl placeholder
            .f = ~ sum(!is.na(.)) < (min_coverage * window) | (length(.) < window), # . as we still operate inside the sliding window. How many values are inside 
            #the sliding window. Add length condition analog to .complete in slider. But produces a logical result for better human readability.
            .before = window - 1, # -1 as slider counts the present examined value, as well as the previous ones. 
            .after = 0),
          .names = "{.col}_coverage_problem"
        )
      )
    
    
    if(metric == "range") { 
      marked_detections_df <- coverage_problem_detected |>
        mutate( # uses the output of the across() function to generate a column for each variable in names(thresholds). The name is provided by .names.
          across(
            .cols = names(thresholds),
            .fns = ~ slider::slide_lgl( # slide_dbl function as the function argument for across to run for every measurement variable
              .x = .x, # .x the vector from the across command. means the current variable.
              # "." convention as placeholder to separate the operational area of across and slider_dbl placeholder
              .f = ~ if(is.na(dplyr::last(.)) || sum(!is.na(.)) < (min_coverage * window)) { # NA check before the statistical metric is calculated. For the case
                # coverage_problem okay, value in question = NA OR min coverage not reached.
                NA # return NA for the measurement values that cant be tested.
              }else { # range case
                max(., na.rm = TRUE) - min(., na.rm = TRUE) < unname(thresholds[[dplyr::cur_column()]]["range"]) # cur_column get the name of the variable 
                #currently processed
                #accessing the range threshold for comparison. # unname as only the value is required not range = X.
                # . as we still operate inside the sliding window. How many values are inside the sliding window.
              }, 
              .before = window - 1, # -1 as slider counts the present examined value, as well as the previous ones. 
              .after = 0,
              .complete = TRUE),
            .names = "{.col}_CVE"
          )
        )
      
    } else{
      marked_detections_df <- coverage_problem_detected |>
        mutate( # uses the output of the across() function to generate a column for each variable in names(thresholds). The name is provided by .names.
          across(
            .cols = names(thresholds),
            .fns = ~ slider::slide_lgl(
              .x = .x, 
              .f = ~ if(is.na(dplyr::last(.)) || sum(!is.na(.)) < (min_coverage * window)) { # NA check before the statistical metric is calculated. For the case coverage_problem okay, value in question = NA
                NA 
              }else {
                sd(., na.rm = TRUE) < unname(thresholds[[dplyr::cur_column()]]["sd"]) 
              },
              
              .before = window - 1, 
              .after = 0,
              .complete = TRUE),
            .names = "{.col}_CVE"
          )
        )
     }
    
    # Reporting section for both options range and sd within source_ids workflow
    # coverage problems filter
    coverage_problems <- marked_detections_df |>
      filter(
        if_any(
          .cols = ends_with("coverage_problem"), # Column selection scheme using the end of the column names defined in .names above to select the columns
          # containing the detection information generated from the marked_detections_df pipeline.
          .fns = ~ !is.na(.x) & .x, #Report all rows that have a coverage problem and is not NA
        )
      )
    
    # $data filter
    detected_records <- marked_detections_df|>
      filter(
        if_any(
          .cols = ends_with("_CVE"), # Column selection scheme using the end of the column names defined in .names above to select the columns
          # containing the detection information generated from the marked_detections_df pipeline.
          .fns = ~ !is.na(.x) & .x
        )
      )
    
    #detection summary reporting detected results excluding the values who failed min_coverage.
    detection_summary <- marked_detections_df |> 
      summarise( # summarise always summarises the row-based results and expresses them in a number.
        n_total_tested     = sum(!is.na(c_across(ends_with("_CVE")))), #c_across to aggregate the statistics over multiple columns here all that end with CVE.
        n_total_detected   = sum(c_across(ends_with("_CVE")), na.rm = TRUE), # na.rm ignores NA to achieve a calculation result.
        pct_total_detected = round(n_total_detected / n_total_tested * 100, digits = 2),
          
          across( #Entering variable specific reporting workflow using across()
            .cols = ends_with("_CVE"),
            .fns = list(
              n_group          = ~ sum(!is.na(.x)),
              n_detected       = ~ sum(.x, na.rm = TRUE), # sum for all records inside a certain group that are TRUE (detected)
              pct_detected     = ~ round(sum(.x, na.rm = TRUE) / sum(!is.na(.x)) * 100, digits = 2)), # denominator counts every value excepct NA.
            .names = "{.fn}_{.col}"
        )
      ) |> 
      rename_with(~ stringr::str_remove(.x, "_CVE"), .cols = contains("CVE")) # remove the _CVE content from the column names
    
    message(
      paste0(
        "The Peristence Test has been executed successfully on a single data frame .\n",
        "In total '", detection_summary$n_total_tested, "' values have been examined.\n",
        "From which '", detection_summary$n_total_detected, "' values failed the test.\n",
        "This makes a total percentage of '", detection_summary$pct_total_detected, "'%.\n\n", 
        "Check detection_summary in the generated list inside the global environment ",
        "for a detailed description for each measurement value.\n\n", 
        "The $data point inside this list shows all rows where at least one\n ",
        "measurement value has failed the test.\n",
        "$coverage_problems show the values which have not been tested as they\n",
        "did not exceed the minimum amount of required values."
      )
    )
    
    return(list(
      data = detected_records,
      detection_summary = detection_summary,
      coverage_problems = coverage_problems
    ))
  
  }
  
}
  
  