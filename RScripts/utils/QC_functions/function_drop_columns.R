#======================================================================
# Scriptname: utils/function_drop_columns.R
# Function name: drop_columns
# Goal(s): 
  # Remove selected columns from a data frame.
  # Warn if configured columns are not present in the data frame.
# Author: Kai Albert Zwießler
# Outputs:
  # data frame without selected columns
  # informs via message() about columns that are assigned in the configuration but are not present in the data frame. This helps to detect changes in format or erroneously removed columns
#======================================================================

#' @param df data frame or tibble
#' @param column_selection character vector containing column names that
#' should be removed from the data frame. Typically defined in the configuration file.
#' @return data frame or tibble with the selected columns removed.
#' @export

drop_columns <- function(df, column_selection = NULL) {
  
  # Input validation
  if (!is.data.frame(df)) stop("`df` must be a data.frame or tibble.")
  if (is.null(column_selection)) stop("column_selection must be specified in the configuration file usually assigned: DROP_COLUMNS")
  if (!is.character(column_selection)) stop("'column_selection' must be a character vector.") # Character string validation
  if (length(column_selection) == 0) stop("column_selection must contain at least one column name.")

  # # Identify configured columns that are not present in the data frame
  missing_drop_cols <- setdiff(
    column_selection,
    names(df)
  )
  
  if(length(missing_drop_cols) > 0){
    message(
      "Configured columns not found in data frame: ",
      paste(missing_drop_cols, collapse = ", ")
    )
  }
  
  # Removing columns
  df <- dplyr::select(
    df,
    -dplyr::any_of(column_selection)
  )
  
  return(df)
}

