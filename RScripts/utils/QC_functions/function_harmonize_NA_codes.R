#======================================================================
# Script name: function_harmonize_NA_codes.R
# Function name: harmonize_NA_codes()
#======================================================================

#' @title Function to harmonize \code{NA} values of different types.
#' 
#' @description Different countries, practices or devices produce different \code{NA_codes} (missing codes). This function is there to harmonize the missing
#' codes to enable collective treatments. The function has been generated as a part of a data pipeline for hydrometeorological data.
#' 
#' @details 
#' The functions converts user-defined missing codes function internally to \code{NA}.
#' 
#' A reporting message is provided in the console on how many missing codes have been converted.
#' In the report only the codes that are converted and are defined in \code{NA_codes} are reported. Already existing \code{NA} are not taken
#' into consideration.
#' 
#' @note The examples of the missing codes do not claim comprehensiveness. It is suggested to adjust the missing codes on the requirement of the
#' present data set.
#' 
#' @param df data frame or tibble.
#' @param measurement_columns Character vector. Containing the names of the columns where missing codes can appear.
#' @param NA_codes Character vector. Containing all the different missing codes present in the data sets.
#' @examples 
#' c("", " ", "S/D", "-999", "-888.88", "-888.9", "N/A")
#' 
#' @return data frame or tibble with harmonized \code{NA_codes}.
#' 
#' @author Kai Albert Zwießler
#' @export


harmonize_NA_codes <- function(df, measurement_columns = NULL, NA_codes = NULL) {
  
  # Input validation
  if (!is.data.frame(df)) stop("`df` must be a data.frame or tibble.")
  if (is.null(NA_codes)) stop("`NA_codes` must be specified in the configuration file.")
  if (!is.character(NA_codes)) stop("`NA_codes` must be a character vector.")
  if (is.null(measurement_columns)) stop("The columns where the missing code harmonization shall be applied to have to be specified.")
  if (!is.character(measurement_columns)) stop("`measurement_columns` must be a character vector.")
  if (length(NA_codes) < 2) stop("`NA_codes` must contain at least two entries.")
  
  #validation if the cols in measurement cols are present in df.
    missing_cols <- setdiff(measurement_columns, names(df))
    if(length(missing_cols) > 0){
    stop(
      paste(
        "The following measurement columns are missing:",
        paste(missing_cols, collapse = ", ")
      )
    )
  }

  # Missing codes count and missing code substitution
  n_replaced <- 0
  
  for(col in measurement_columns){
    
    n_replaced <- n_replaced +
      sum(df[[col]] %in% NA_codes, na.rm = TRUE)
    
    df[[col]][df[[col]] %in% NA_codes] <- NA
  }

  message(
    "Function harmonize_NA_codes report: ",
    n_replaced,
    " missing codes were converted to NA."
  )
  
return(df) 
}