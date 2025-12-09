#======================================================================
# Scriptname: utils/function_time.R
# Function name: calc_time_diff()
# Goal(s): 
  # Generating a function that calculates the time difference in minutes from one timestep to another the result will be safed into a seperate column. The Goal is to ensure temporal consistency.
  # Temporal Consistency test
# Author: Kai Albert Zwießler
# Date: 2025.11.18
# Outputs: 

# Units:
  # minutes
#======================================================================

#' calc_time_diff
#' 
#' Calculate time difference (in minutes) of each individual device and add column
#' Generic forpiezometer, WLS, meteorological stations.
#' # ========== CONFIGURATION ==========
#' @param df data.frame
#' @param id_col string: Name der ID-Spalte
#' @param date_col string: Name der Zeit-Spalte (default "Date")
#' @param out_col string: Name der Ausgabespalte (default "time_diff")
#' @param units string: units für difftime (default "mins")
#' @return tibble mit zusätzlicher Spalte out_col
#' @export


calc_time_diff <- function(df, id_col, date_col = "Date", out_col = "time_diff",
                           units = "mins") {
# GPE: If no column names of the loaded input_file contains the stringed "id_column" then the function immediately stops and prints an error message.

  if (!id_col %in% names(df)) stop(sprintf("id_col '%s' not found in input_file, df.", id_col))
  if (!date_col %in% names(df)) stop(sprintf("date_col '%s' not found in input_file, df.", date_col))
 
# Convertion of strings with characters, containing column information, to symbols. The conversion helps to assign a symbol in the function section so that !!sym() dosent have to be converted inside the code. Dplyr internal logic.
 cat("=== Strings to symbols ===")  
  id_column <- rlang::sym(id_col)
  date_column <- rlang::sym(date_col)
  output_column  <- rlang::sym(out_col)

# Generating output_column "time_diff"
  
df <- df %>% # df will be later assigned to the used data frame
  group_by(!!id_column) %>% #grouped by id
  arrange(!!id_column, !!date_column) %>%
  mutate(
  !!output_column :=
  as.numeric(difftime(!!date_column, lag(!!date_column), units = units)) # generating a new column with :=. difftime() function
  ) %>%
  ungroup()
  
  return(df)
}
