#======================================================================
# Scriptname: utils/function_harmonize_NA_codes.R
# Function name: harmonize_NA_codes
# Goal(s): 
  # harmonize_NA_codes like S/D, NA, " " to "NA"
  # Message how many conversions were executed.
# Author: Kai Albert Zwießler
# Date: 2026.06.14
# Outputs:
  # data frame or tibble with adjusted NA codes
#======================================================================

#' @param df data frame or tibble
#' @param measurement_columns Character vector containing the
#' names of the measurement columns to be harmonized.
#' @param NA_codes Character vector containing all missing value
#' codes present in the data sets.
#' @return data frame or tibble with harmonized NA codes
#' @export


harmonize_NA_codes <- function(df, measurement_columns = NULL, NA_codes = NULL) {
  
  # Input validation
  if (!is.data.frame(df)) stop("`df` must be a data.frame or tibble.")
  if (is.null(NA_codes)) stop("NA_codes must be specified in the configuration file.")
  if (!is.character(NA_codes)) stop("'NA_codes' must be a character vector.")
  if (is.null(measurement_columns)) stop("The columns where the missing code harmonization shall be applied have to be specified.")
  if (!is.character(measurement_columns)) stop("'measurement_columns' must be a character vector.")
  if (length(NA_codes) < 2) stop("NA_codes must contain at least two entries.")
  
  
    missing_cols <- setdiff(measurement_columns, names(df))
    if(length(missing_cols) > 0){
    stop(
      paste(
        "The following measurement columns are missing:",
        paste(missing_cols, collapse = ", ")
      )
    )
  }

  # Missing codes count and missing code substitution
  n_replaced <- 0
  
  for(col in measurement_columns){
    
    n_replaced <- n_replaced +
      sum(df[[col]] %in% NA_codes, na.rm = TRUE)
    
    df[[col]][df[[col]] %in% NA_codes] <- NA
  }

  message(
    n_replaced,
    " missing codes were converted to NA."
  )
  
return(df) 
}