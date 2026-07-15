#======================================================================
# Script name: function_calc_time_diff.R
# Function name: calc_time_diff()
# Goal(s): 
  # Generating a function that calculates the time difference (in minutes) from one time step to another 
  # the result will be saved into a separate column.
  # Th Goal is to ensure temporal continuity and avoid temporal gaps.
# Author: Kai Albert Zwießler
# Date: 2025.11.18
# Outputs: 

# Units:
  # minutes
#======================================================================

#' @title calc_time_diff
#' 
#' Calculate time difference (in minutes) of each individual device and add column
#' Generic forpiezometer, WLS, meteorological stations.
#' # ========== CONFIGURATION ==========
#' @param df data.frame
#' @param id_column string: Name of the ID-column (Default "ID")
#' @param date_column string: Name of the date-column (default "Date")
#' @param output_column string: Name of the output-column (default "time_diff")
#' @param units string: units for difftime (default "mins")
#' @return tibble with an additional output column, containing the colucalted results
#' @seealso This function is a preparation step for the temporal gap-analysis
#'  \code{\link{function_timediff_sum}}} Builds on the calculated time steps and provides a comprehensive summary of the different time intervals
#'  of the data set.
#'  \code{\link{interval_determination}}} Also aprt of the workflow to extract the individual rows which cause 
#' @export


calc_time_diff <- function(df, id_column = "ID", date_column = "Date", output_column = "time_diff",
                           units = "mins") {
# Good practice example: If no column names of the loaded input_file contains the stringed "id_column" then the function immediately stops and prints an error message.

  if (!id_column %in% names(df)) stop(sprintf("id_column '%s' not found in input_file, df.", id_column))
  if (!date_column %in% names(df)) stop(sprintf("date_column '%s' not found in input_file, df.", date_column))
  # check for column type POSIXct
  if (!inherits(df[[date_column]], "POSIXct")) {
    stop(sprintf("The column '%s' must be of type POSIXct.", date_column))
  }
 
# Conversion of strings with characters, containing column information, to symbols. The conversion helps to assign a symbol in the function section so that !!sym() dosent have to be converted inside the code. Dplyr internal logic.
  
  id_column <- rlang::sym(id_column)
  date_column <- rlang::sym(date_column)
  output_column  <- rlang::sym(output_column)

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
