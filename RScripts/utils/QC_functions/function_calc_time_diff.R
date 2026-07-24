#======================================================================
# Script name: function_calc_time_diff.R
# Function name: calc_time_diff()
#======================================================================

#' @title Calculation of differences in time steps
#' 
#' @description Calculate time difference (in minutes) of each individual device and stores the results in a separate column.
#' 
#' @details The time stamps are sorted either by the information from \code{id_column} and \code{date_column} or only by \code{date_column}
#' 
#' @note This function is the prerequisite for any other functions to analyse temporal continuity.
#' Dependencies are explained below
#' 
#' By definition of the timediff() function the first value is \code{NA} as no difference can be calculated.
#' 
#' @param df Master data.frame with station identifiers or single data frame.
#' @param id_column Character string. With the name of the ID-column in \code{df}. The specification of this
#' column enables station internal calculations.
#' @param date_column Character string. Name of the date column in \code{df}.
#' @param output_column Character string. Used to determine the name of the generated output column Default "time_diff".
#' @param units Character string. Units information in which the difftime function calculation shall take place. Default "mins".
#' 
#' @return tibble with an additional output column, containing the calculated, temporal differences from one time step to the next.
#' 
#' @seealso This function is a preparation step for the temporal gap-analysis
#'  \code{\link{function_timediff_sum}}} Builds on the calculated time steps and provides a comprehensive summary of the different time intervals
#'  of the data set.
#'  \code{\link{interval_determination}}} Also part of the temporal continuity  examination workflow to extract the individual rows assigned to
#'  the group where the calculated time difference is situated.
#' @author Kai Albert Zwießler
#'  
#' @export


calc_time_diff <- function(df, id_column = NULL, date_column = NULL, output_column = "time_diff",
                           units = "mins") {


  #date_column verification
  if (is.null(date_column)){
    stop("`date_column` needs to be specified for the calculation of temporal differences.")
  }
  
  if (!date_column %in% names(df)){
    stop(sprintf("date_column '%s' not found in input_file, df.", date_column))
  }
  
  # check for column type POSIXct
  
  if (!inherits(df[[date_column]], "POSIXct")) {
    stop(sprintf("The column '%s' must be of type POSIXct.", date_column))
  }
  
  # id_column verification
  
  if (!is.null(id_column) && !id_column %in% names(df)){
    stop(sprintf("id_column '%s' not found in input_file, df.", id_column))
  }

  
# Conversion of strings with characters, containing column information, to symbols. The conversion helps to assign a symbol in the function section so that !!sym() dosent have to be converted inside the code. Dplyr internal logic.
  
  date_column <- rlang::sym(date_column)
  output_column  <- rlang::sym(output_column)


  
  # Generating output_column "time_diff"
  if(!is.null(id_column)){
    id_column <- rlang::sym(id_column)
  
    df <- df %>% # df will be later assigned to the used data frame
      group_by(!!id_column) %>% #grouped by id
        arrange(!!id_column, !!date_column) %>%
          mutate(
            !!output_column :=
              as.numeric(difftime(!!date_column, lag(!!date_column), units = units)) # generating a new column with :=. difftime() function
          ) %>%
      ungroup()
      
  } else {
  df <- df %>%
    arrange(!!date_column) %>%
      mutate(
        !!output_column :=
          as.numeric(difftime(!!date_column, lag(!!date_column), units = units)) # generating a new column with :=. difftime() function
      )
  
  
     
  }
  
  return(df)
}
  
