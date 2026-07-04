#======================================================================
# Scriptname: load_qk_csv.R
# Function name: load_qk_csv
#
# Goal(s):
#   Import and standardize raw meteorological data from the
#   Qori-Kalis automatic weather station.
#
#   Workflow:
#     - Import raw .csv files
#     - Preserve source file information (Source.Code)
#     - Clean and harmonize raw column headers
#     - Translate Spanish and German column names
#     - Add missing required columns
#     - Rename columns according to project standards
#     - Remove import artefacts
#     - Parse datetime information to POSIXct format
#     - Add station identifier (ID)
#     - Remove temporary columns
#     - Combine all files into a single standardized data frame
#
# Author: Kai Albert Zwießler
# Date: 2026.06.10
#
# Input:
#   Raw .csv files exported from the Qori-Kalis weather station
#
# Output:
#   Standardized meteorological data frame ready to unite with other meteorological data
#   and subsequent preprocessing and QC tasks.

#======================================================================

#' Import and standardize Qori-Kalis meteorological data
#'
#' Imports all configured Qori-Kalis raw csv files and applies the
#' complete harmonization workflow:
#' header cleaning, translation, column completion,
#' column renaming, removal of import artefacts,
#' datetime parsing and station ID assignment.
#'
#' @param cfg configuration list containing all station specific settings.
#' @param timezone Olson timezone used for datetime parsing.
#'
#' @return Tibble containing all imported and standardized
#' Qori-Kalis meteorological observations.
#'
#' @export

load_qk_csv <- function(cfg, timezone) {
  
  # Create file list
  datapaths <- list.files(
    cfg$FOLDER,
    pattern = "\\.csv$",
    full.names = TRUE
  )
  
  datapaths_named <- setNames(
    datapaths,
    basename(datapaths)
  )
  
  if (!is.null(cfg$KEEP_FILES)) {
    datapaths_named <- datapaths_named[
      names(datapaths_named) %in% cfg$KEEP_FILES
    ]
  }
  
  # Import individual files
  data_list <- purrr::imap(
    datapaths_named,
    \(x, file_name) {
      
      df <- read.csv(
        x,
        skip = 1,
        colClasses = "character",
        check.names = FALSE
      )
      
      df$Source.Code <- file_name
      
      df
    }
  )
  
  # Header cleaning
  data_list <- purrr::map(
    data_list,
    \(df) {
      names(df) <- clean_headers_qk(names(df))
      df
    }
  )
  
  # Translation
  data_list <- purrr::map(
    data_list,
    \(df) {
      names(df) <- translate_headers_qk(
        names(df),
        translation_map = TRANSLATION_MAP_QK
      )
      df
    }
  )
  
  # Add missing columns
  data_list <- purrr::map(
    data_list,
    \(df) {
      ensure_required_columns_qk(
        df,
        required_columns = names(COLUMN_RENAME_MAP_QK)
      )
    }
  )
  
  # Rename columns
  data_list <- purrr::map(
    data_list,
    \(df) rename_columns(df, COLUMN_RENAME_MAP_QK)
  )
  
  # Remove import artefacts
  data_list <- purrr::map(
    data_list,
    \(df) drop_columns(
      df,
      cfg$DROP_IMPORT_COLUMNS_QK
    )
  )
  
  # Parse datetime
  data_list <- purrr::map(
    data_list,
    \(df) parse_datetime_column(
      df,
      date_column = cfg$DATE_COLUMN,
      timezone = TIMEZONE_DATA
    )
  )
  
  # Add station ID
  data_list <- purrr::map(
    data_list,
    \(df) {
      dplyr::mutate(
        df,
        ID = cfg$ID
      )
    }
  )
  
  # Remove final columns
  data_list <- purrr::map(
    data_list,
    \(df) drop_columns(
      df,
      cfg$DROP_COLUMNS_FINAL
    )
  )
  
  # Combine files
  data_qk <- dplyr::bind_rows(data_list)
  
  return(data_qk)
}