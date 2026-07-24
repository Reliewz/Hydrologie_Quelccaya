#======================================================================
# Script name: function_drop_columns.R
# Function name: drop_columns()
#======================================================================

#' @title Function to remove columns
#' 
#' @description Used to quickly remove columns from \code{df}. 
#' 
#' @details Input validation for the case in \code{column_selection} are columns defined that do not exist in \code{df}.
#' 
#' @param df data frame or tibble
#' @param column_selection character vector. Containing column names that will be removed from \code{df}.
#' 
#' @return data frame or tibble where the specified columns are removed.
#' @author Kai Albert Zwießler
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

