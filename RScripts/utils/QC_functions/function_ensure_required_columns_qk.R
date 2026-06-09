#======================================================================
# Scriptname: utils/function_ensure_required_columns_qk.R
# Function name: ensure_required_columns_qk
# Goal(s):
  # Ensure that all required columns are present.
  # Missing columns are added and filled with NA values.
  # unexpected columns are reported to support quality control

# Author: Kai Albert Zwießler
# Date: 2026.06.09
  # Input:  data frame or tibble
  # Output: data frame or tibble where columns are added and filled with "NA" values
#======================================================================

#' @param df data frame or tibble
#' @param required_columns character vector containing the expected raw
#' column names required for data harmonization.
#' @return data frame or tibble containing all required columns.
#' Missing columns are added and filled with NA values.
#' @export


ensure_required_columns_qk <- function(df, required_columns = NULL
) {
  # Input Validation
  if (!is.data.frame(df)) stop("`df` must be a data.frame or tibble.")
  if (is.null(required_columns)) stop("required_columns must be specified and is usually identical to COLUMN_RENAME_MAP_QK")
  if (!is.character(required_columns)) stop("'required_columns' must be a character vector.") # Character string validation
  
  unexpected_cols <- setdiff(
    names(df),
    required_columns
  )
  
  if(length(unexpected_cols) > 0){
    warning(
      "Unexpected columns found in the data frame ",
      "but are not specificly defined in the character vector of required_columns and will therfore not be processed by ",
      "the standard harmonization workflow: ",
      paste(unexpected_cols, collapse = ", "))
  }
  
  # logic to add columns which are not existing
  missing_cols <- setdiff(
    required_columns,
    names(df)
  )
  
  
  # logic to add columns.
  for(col in missing_cols){
    df[[col]] <- NA
        }
  if(length(missing_cols) > 0){
    message(
      "Added missing columns: ",
      paste(missing_cols, collapse = ", ")
    )
  }
    
return(df) 
}