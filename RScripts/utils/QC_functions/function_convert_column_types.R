#======================================================================
# Script name: function_convert_column_types.R
# Function name: convert_column_types()
#======================================================================

#' @title Converting column-types and their order.
#' 
#' @description According to the parameter \code{column_definition} the column-type and it's order are changed inside \code{df}.
#' 
#' @details 
#' A validation step is integrated, testing if the exact amount of columns defined in \code{column_definition} are present in \code{df} and vice versa.
#' 
#' The following types are supported: "numeric","character","POSIXct","logical","integer"
#' 
#' 
#' @note Non-convertible values (e.g., non-numeric strings in numeric columns) will be coerced to NA during type conversion
#' @seealso Explicit missing value codes should be handled prior using harmonize_NA_codes().
#' \code{\link{harmonize_NA_codes}}
#' 
#' @param df data frame or tibble.
#' @param column_definition Named list. Containing the column names and types. The order in which the columns are arranged will be used to arrange \code{df}.
#' @examples Dont run this code.
#' list(
#' Date        = "POSIXct",
#' ID          = "character",
#' AirTC       = "numeric")
#' 
#' @param timezone time zone in which the data has been recorded.
#' 
#' @return data frame or tibble with arranged and harmonized column-types according to the configuration.
#' @author Kai Albert Zwießler
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
  
  # Vice versa verification missing in configuration file but extra in data frame
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