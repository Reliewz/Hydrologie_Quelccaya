#======================================================================
# Script name: function_ensure_required_columns_qk.R
# Function name: ensure_required_columns_qk()
#======================================================================

#' @title Harmonize columns across data frames or tibbles
#' 
#' @description Used as a controlled, reproducible step to add columns before joining multiple data frames or tibbles.
#' 
#' @details Validation if all columns are defined in data frame that are defined in required_columns
#' 
#' Missing columns will be added and filled with \code{NA}.
#' 
#' @param df data frame or tibble.
#' @param required_columns Character vector. Containing all the required column names wanted for column harmonization.
#' 
#' @return data frame or tibble with harmonized amount of columns, where missing columns are filled with \code{NA}.
#' @author Kai Albert Zwießler
#' @export


ensure_required_columns_qk <- function(df, required_columns = NULL
) {
  # Input Validation
  if (!is.data.frame(df)) stop("`df` must be a data.frame or tibble.")
  if (is.null(required_columns)) stop("required_columns must be specified.")
  if (!is.character(required_columns)) stop("'required_columns' must be a character vector.") # Character string validation
  
  unexpected_cols <- setdiff(
    names(df),
    required_columns
  )
  
  if(length(unexpected_cols) > 0){
    warning(
      "Unexpected columns found in the data frame/n",
      "but are not specificly defined in the character vector of `required_columns`. This columns will not be processed by/n",
      "this column-harmonization step: ",
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