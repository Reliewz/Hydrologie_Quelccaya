#======================================================================
# Scriptname: utils/function_rename_columns.R
# Function name: rename_columns()
# Goal(s):
#   Renames columns of a data frame or tibble based on a named character
#   vector. The mapping is defined in the configuration file, keeping
#   the function generic and reusable across different datasets.
# Author: Kai Albert Zwießler
# Date: 2026.05.30
# Input:  df            - data frame or tibble
#         rename_map    - named character vector defined in config
# Output: tibble with renamed columns
#======================================================================


#' Renames columns of a data frame or tibble based on a named character vector.
#' Only columns present in the data frame are renamed. Columns not listed in
#' \code{rename_map} remain unchanged.
#'
#' The \code{rename_map} must be defined in the configuration file as a named
#' character vector with the following structure:
#' \preformatted{
#' COLUMN_RENAME <- c(
#'   "old_column_name" = "new_column_name",
#'   "Abs.Druck..kPa"  = "Abs_pres"
#' )
#' }
#'
#' @param df data.frame or tibble to rename columns in
#' @param rename_map named character vector where names are the original column
#'   names and values are the desired new column names. Defined in the
#'   configuration file.
#' @return tibble with renamed columns
#' @export


rename_columns <- function(df, rename_map = NULL){
  
 
  # Input Validation
  if (!is.data.frame(df)) stop("`df` must be a data.frame or tibble.")
  if (is.null(rename_map)) stop("rename_map must be specified.")
  if (!is.character(rename_map)) stop("'rename_map' must be a character vector.") # Character string validation

  # Validation if rename_map has entries but they do not match with the original column names
  not_found <- names(rename_map)[!names(rename_map) %in% names(df)]
  if (length(not_found) > 0) {
    stop(sprintf("The original column names: %s must match the old column names defined in rename_map.", paste(not_found, collapse = ", ")))
    }  

  # Rename columns reverse for natural customization
  df <- df %>%
    dplyr::rename(all_of(setNames(names(rename_map), rename_map)))
  
  
  
  # Final validation
  message("Renamed columns. Current column names: ", paste(names(df), collapse = ", "))
  
return(df)  
}
  