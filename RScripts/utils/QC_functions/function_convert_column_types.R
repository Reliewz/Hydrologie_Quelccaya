#======================================================================
# Scriptname: utils/function_convert_column_types.R
# Function name: convert_column_types
# Goal(s): 
  # Convert column types according to the requirements of the measurement value defined in the configuration file
  # changes order of columns according to the order of the defined list
  # validates if all columns have been assigned in the configuration file that exist in the data frame.
  # Cross check for valid column type. Supports the following types: "numeric","character","POSIXct","logical","integer".
# Author: Kai Albert Zwießler
# Date: 2026.06.23
# Outputs:
  # data frame or tibble with adjusted column types
#======================================================================

#' #' Note:
#' Non-convertible values (e.g., non-numeric strings in numeric columns)
#' will be coerced to NA during type conversion.
#' Explicit missing value codes should be handled prior using
#' harmonize_NA_codes().
#' @param df data frame or tibble
#' @param column_definition list containing the
#' column names and types.
#' @param timezone time zone in which the data has been recorded
#' @return data frame or tibble with harmonized NA codes
#' @export


convert_column_types <- function(df, column_definition = NULL, timezone = NULL) {
  
  # Input validation
  if(!is.data.frame(df)) stop("`df` must be a data.frame or tibble.")
  if(is.null(column_definition)) stop("The column_definition parameter have to be specified in the configuration file.")
  if(is.null(names(column_definition))) stop("The column_definition parameter have to be specified in the configuration file and must contain column names.")
  if(is.null(timezone)){ stop("The timezone parameter must be specified.")}
  if(!is.list(column_definition)){ stop("'column_definition' must be a named list.")}
  if(!is.character(timezone)){ stop("'timezone' must be a character string.")}
  
  # validation if the data frame contains the same columns as assigned in the configuration file
  missing_cols <- setdiff(
    names(column_definition),
    names(df)
  )
  if(length(missing_cols) > 0){
    stop(
      paste(
        "The following columns are assigned in the configuration file but are missing in the data frame:",
        paste(missing_cols, collapse = ", ")
      )
    )
  }
  
  # Visa versa verification missing in configuration file but extra in data frame
  extra_cols <- setdiff(
    names(df),
    names(column_definition)
  ) 
    if(length(extra_cols) > 0) {
      stop(
        paste(
          "The data frame contains additional columns that are not defined in the configuration file.:", paste(extra_cols, collapse = ", "),
          "The columns in the configuration file need to match the ones in the data frame. To remove columns use the drop_column function.",
        )
      )
  }
  
  # Determination of valid column types
  valid_types <- c(
    "numeric",
    "character",
    "POSIXct",
    "logical",
    "integer"
  )
  
  # Type conversion
  for(col in names(column_definition)){
    
    type <- column_definition[[col]]
    
    # Validation of suitable column types
    if(!type %in% valid_types){
      stop(
        paste(
          "A unsupported column type is used in the configuration file:",
          type
        )
      )
    }
    
    if(type == "numeric"){
      df[[col]] <- as.numeric(df[[col]])
    }
    
    if(type == "character"){
      df[[col]] <- as.character(df[[col]])
    }
    
    # conversion date column
    if(type == "POSIXct"){
      if(!inherits(df[[col]], "POSIXct")){
        df[[col]] <- as.POSIXct(
          df[[col]],
          tz = timezone
        )
        
      }
      
    }
    if(type == "logical"){
      df[[col]] <- as.logical(df[[col]])
    }
    if(type == "integer"){
      df[[col]] <- as.integer(df[[col]])
    }
  }
  
  df <- df[, names(column_definition)]
  
  
  
  return(df)
}