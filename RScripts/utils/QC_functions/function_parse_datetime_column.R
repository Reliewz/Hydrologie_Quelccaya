#======================================================================
# Script name: function_parse_datetime_column.R
# Function name: parse_datetime_column()
#======================================================================

#' @title Parse a column containing date and time into POSIXct format.
#'
#' @desciprtion
#' Converts a character-based datetime column to a POSIXct datetime object
#' using the specified timezone. A new column named "Date" is created and added to the input data frame.
#'
#' @param df data frame or tibble containing the raw datetime column.
#' @param date_column character string. containing the name of the raw name of the column with the date and time information.
#' @param timezone character string. Containing the timezone in which the sensor has been recorded. 
#' Must be a valid Olson timezone name.
#' @examples
#' \dontrun{
#' Examples are:
#' TIMEZONE_DATA <- "America/Lima"
#' TIMEZONE_PROCESS <- "Europe/Berlin"}
#' @param orders Character string. Describing the original datetime format compatible with lubridate::parse_date_time(). Default = "mdy IMS p".
#' Others can be specified if required.
#' 
#' @return data frame or tibble containing an additional column named "Date" from type \code{POSIXct} according to ISO 8601 YYYY.MM.DD hh:mm:ss standards and added
#' \code{timezone} information.
#' 
#' @author Kai Albert Zwießler
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