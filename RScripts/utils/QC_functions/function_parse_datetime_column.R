#======================================================================
# Scriptname: utils/parse_datetime_column.R
# Function name: parse_datetime_column
# Goal(s):
  # Converting date column into ISO format YYYY.MM.DD hh:mm:ss and POSIXct date type
  # Adding timezone information to the date column

# Author: Kai Albert Zwießler
# Date: 2026.06.10
# Input:  data frame or tibble
# Output: data frame or tibble with converted date columns
#======================================================================

#' Parse a raw datetime column into POSIXct format
#'
#' Converts a character-based datetime column to a POSIXct datetime object
#' using the specified timezone. A new column named "Date" is created and
#' added to the input data frame.
#'
#' @param df data frame or tibble containing the raw datetime column.
#' @param date_column character string containing the name of the raw
#' datetime column to be converted.
#' @param timezone character string defining the timezone used for datetime
#' parsing. Must be a valid Olson timezone name.
#' @param orders character string describing the original datetime format
#' used by lubridate::parse_date_time(). Default = "mdy IMS p".
#' @return data frame or tibble containing an additional POSIXct column
#' named "Date".
#'
#' @export



parse_datetime_column <- function(
    df,
    date_column = NULL,
    orders = "mdy IMS p",
    timezone = NULL
){
  # Input validation
  if (!is.data.frame(df)) stop("`df` must be a data.frame or tibble.")
  if (is.null(date_column)) stop("The original name of the date column is not assigned. This prevents a later applied date conversion step.")
  if (is.null(timezone)) stop("timezone must be specified. Example: 'America/Lima', 'Europe/Berlin'. See OlsonNames() for all valid options.")
  if (!timezone %in% OlsonNames()) stop(sprintf("'%s' is not a valid timezone. See OlsonNames() for valid options.", timezone))
  if (!date_column %in% names(df)) {
    stop(sprintf(
      "Column '%s' not found in df.",
      date_column
    ))
  }
  if (!is.character(orders)) {
    stop("orders must be a character string.")
  }
 
  df$Date <- lubridate::parse_date_time(
    df[[date_column]],
    orders = orders,
    tz = timezone
  )
  
  return(df)
}