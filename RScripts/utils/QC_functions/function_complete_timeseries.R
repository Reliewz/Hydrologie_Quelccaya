#======================================================================
# Scriptname: utils/function_complete_timeseries.R
# Function name: complete_timeseries
# Goal(s): 
  # 
# Author: Kai Albert Zwießler
# Date: 2026.07.02
# Outputs:
  # data frame or tibble with completed time series for the selected data
#======================================================================

#' @note Completes missing time steps for selected time series within a master data frame. The function is intended for multi-sensor data sets where individual series are identified via a grouping column (e.g. Source.Code or ID).
#' @param df data frame or tibble
#' @param date_column Column which contains the temporal information for the beginning and end of the completion range Default: Date.
#' @param time_step Temporal resolution that is assumed for the input time series and used interval for the generation of missing time steps
#' (possible entries are "15 min", "30 min", "60 min", "1 hour" or "1 day")
#' @param source_column Character string. Specifying the column that contains the values provided in `source_ids`.
#' @param source_ids Character vector defining the groups that should undergo temporal completion. 
#' Values usually represent file identifiers (Source.Code or SensorID).
#' Individual files of a master data frame can be selected by providing a character vector containing their source name. 
#' Whole hydrological sensors or meteorological stations can be completed by providing a shared identification ID for the whole sensor group.
#' @return data frame or tibble with completed time series
#' @export

complete_timeseries <- function(df, date_column = NULL, time_step = NULL, source_column = NULL, source_ids = NULL){
  
  
  
  
  # --- Input validation
    if (!is.data.frame(df)){ stop("`df` must be a data.frame or tibble.")
    }  
    # date column validation
    if (is.null(date_column)) {
      stop("The name of the `date_column` must be specified as a character string.")
    }
    # date_column character & vector validation
    if (!is.character(date_column) || length(date_column) != 1) {
      stop("`date_column` must be a single character string not a character vector.")
    }
    if (!date_column %in% names(df)) {
      stop(paste("`date_column`", date_column, "not found in `df`."))
    }
    if (!inherits(df[[date_column]], "POSIXct")) {
      stop(paste("Column", date_column, "must be of class POSIXct before this action can be performed."))
    }
    
    # Present temporal interval validation / time_step validation
    if(is.null(time_step)){
      stop("Please specify the `time_step` parameter according to the temporal interval the input data possesses. ")
    }
    if(!is.character(time_step)){
      stop("The `time_step` parameter must be a character string. e.g. (e.g. \"15 min\", \"60 min\", or \"1 day\"). ")
    }
    # Match.arg restriction of time_step parameter
    time_step <- match.arg(
      time_step,
      c(
        "15 min",
        "30 min",
        "60 min",
        "1 hour",
        "1 day"
        )
    )
    
    # conversion of character type time_step parameter input to a numeric value. f.e. "15 mins" to 15 for later use in the function
    time_step_table <- c(
      "15 min" = 15,
      "30 min" = 30,
      "60 min" = 60,
      "1 hour" = 60,
      "1 day" = 1440
    )
    
    # unname() function to remove the name and generate the corresponding numeric value.
    time_step_minutes <- unname(time_step_table[time_step])
    
    
   
     # source_column and source_ids
    if (is.null(source_column) && is.null(source_ids)) {
      stop("Both `source_column` and `source_ids` must be specified.\n",
            "This function is designed for master data frames used in semi-automatic data pipelines.\n",
            "`source_column` defines the grouping column and `source_ids` define either individual files or whole groups (f.e. for complete sensors) that", 
           "should undergo temporal completion."
            )
        }
    if(!is.null(source_column) && is.null(source_ids)){
      stop("The `source_ids` parameter must be specified if `source_column` is provided. Please specify the ID-code for individual data files or sensors. ")
    }
    if(is.null(source_column) && !is.null(source_ids)){
      stop("The `source_column` parameter must be specified. Please specify the column in which the `source_ids` information can be found.")
    }
    if (!is.character(source_column)) {
      stop("`source_column` must be a character string or NULL.")
    }
    if (length(source_column) != 1) {
      stop("`source_column` must be a single character string. No character vector. ")
    }
    if (!source_column %in% names(df)) {
      stop(paste0("`source_column` '", source_column, "' not found in `df`."))
    }
    
    # source_ids
    if (!is.character(source_ids)) {
      stop("`source_ids` must be a character string or character vector.")
    }
    # Check if source_ids values exist in source_column
    missing_source_ids <- source_ids[!source_ids %in% df[[source_column]]]
    if (length(missing_source_ids) > 0) {
      stop(paste0(
        "The following `source_ids` values were not found in provided source_column. '",
        source_column, "': ",
        paste(missing_source_ids, collapse = ", "), "."
      ))
    }
    
    
    
  
    # Add missing time steps according to the selected character vector
    if(!is.null(source_column) && !is.null(source_ids)){
      df <- df %>%
        group_by(.data[[source_column]]) %>%
        
          group_modify(function(.x, .y) { #.x is the grouped data frame; .y is the group key containing the group information
            if(.y[[source_column]] %in% source_ids){
              group_name <- .y[[source_column]]
              
              timestep_check <- difftime(
                  .x[[date_column]],  # end date
                  lag(.x[[date_column]]), # previous date. function lag shifts back the time series.
                  units = "mins" # output time difference in minutes
                  )
          timestep_check <- as.numeric(timestep_check) # convert difftime object to numeric.
          timestep_check <- timestep_check[!is.na(timestep_check)] # remove first NA value in the vector, which is an expected behavior of difftime()
              
          
          # Intermediate check for more than two records. As a requirement for correct timediff calculation.
          if (length(timestep_check) == 0) { # 0 because the expected NA generation of difftime have been removed beforehand. Which includes the case of 1 record for this validation.
            stop(
              paste0(
                "Group '", group_name,
                "' contains fewer than two observations. ",
                "Temporal verification cannot be performed."
              )
            )
          }
          
          
          if(all(timestep_check %% time_step_minutes == 0)){ # modulo sign %% checking if timestep_check is a multiple of time_step.
            return(  
              tidyr::complete(.x,
                !!rlang::sym(date_column) := seq( # := tidy evaluation sign to allow dynamic columns (!!date_column) on the left side which usually    expects expressions
                    from = min(.x[[date_column]]),
                    to   = max(.x[[date_column]]),
                    by   = time_step
                  )))
                  
                
          }else {
            
            stop(
              paste0("Input Group '", group_name, "' contains time intervals that are not multiples ",
                     "of the specified 'time_step' ('", time_step, "').",
                 "This occurs when the input data contains fractional time steps or different temporal intervals. ",
                 "Please correct the temporal structure before re-running `complete_timeseries()`. "))
          }
              
              
          }else {
            return(.x)
            
          }
          }) %>%
        ungroup() # release group selection from group_by mechanism
        return(df)
      
        }
}