#======================================================================
# Script name: function_load_qk_csv.R
# Function name: load_qk_csv()
#======================================================================

#' @title Automatic Folder import and standardization for the meteorological station Qori-Kalis.
#'
#' @description Imports all configured Qori-Kalis raw \code{.csv} files directly after the .hobo transformation and applies the complete standardization and
#' harmonization workflow:
#' header cleaning, translation, column completion,
#' column renaming, removal of import artefacts,
#' datetime parsing and station ID assignment.
#'
#' @details Import and standardization workflow:
#' \enumerate{
#'  \item Import raw .csv files
#'  \item Preserve source file identifier \code{Source.Code}
#'  \item Clean and harmonize column headers using \code{\link{clean_headers_qk}()}.
#'  \item Translate spanish and german column names using \code{\link{translate_headers_qk}()}.
#'  \item Harmonize missing but required columns among the files using \code{\link{ensure_required_columns_qk}()}.
#'  \item Rename columns using \code{\link{rename_columns}()}.
#'  \item Remove columns (import artefacts) using \code{\link{drop_columns}()}.
#'  \item Parse datetime information to POSIXct ISO 8601 format YYYY.MM.DD hh:mm:ss using \code{\link{parse_datetime_column}()}.
#'  \item Add station-level identifier \code{ID}.
#'  \item Final column harmonization using \code{\link{drop_columns}()}.
#'  \item Combine all files into a single standardized data frame using a dplyr::bind_rows logic.
#' 
#' @note 
#' If \code{keep_files} is not specified in the external configuration all \code{.csv} data files are imported. 
#' 
#' The files in the specified folder are from type \code{.csv} and are directly used after the \code{.hobo} coversion using the software HOBOware.
#' 
#' The function uses an external configuration file where all the information to execute the workflow is stored.
#' @examples An example of the parameters and how they are provided is shown below:
#' \dontrun{
#' METEO_SENSOR_IMPORTS <- list(
#' STATION_QK = list(
#' FOLDER = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\STATION_QORIKALIS\\meteo_input_data",
#' KEEP_FILES = c("2_QORIKALIS_20_12_2023.csv", "3_QORIKALIS_30_04_24.csv", "4_QORIKALIS_04_06_24.csv", "5_QORIKALIS_06_08_2024.csv",
#'                 "6_QORIKALIS_12_11_2024.csv", "7_QORIKALIS_24_02_2025.csv", "8_QORIKALIS_22_06_2025.csv", "9_QORIKALIS_07_07_2025.csv",
#'                 "10_QORIKALIS_18_08_2025.csv"),
#'  ID = "QK", DATE_COLUMN = "Date_raw", DROP_IMPORT_COLUMNS_QK = c("Total: Regen, mm", "Total: Lluvia, mm"), DROP_COLUMNS_FINAL = c("Record", "Date_raw", "Dew_point"))
#' }
#' 
#' 
#' The column types are imported as \code{character} type to prevent errors resulting from different and wrong assigned column types.
#' 
#' Character vector. Containing the names of the files which should be selected for the import. The names have to match the names in the folder
#' selected for import.
#'
#' @param cfg External configuration file containing all station specific parameter.
#' @examples An example of the parameters and how they are provided is shown below:
#' \dontrun{
#' METEO_SENSOR_IMPORTS <- list(
#' STATION_QK = list(
#' FOLDER = "D:\\RProjekte\\Hydrologie_Quelccaya\\Datenquellen\\STATION_QORIKALIS\\meteo_input_data",
#' KEEP_FILES = c("2_QORIKALIS_20_12_2023.csv", "3_QORIKALIS_30_04_24.csv", "4_QORIKALIS_04_06_24.csv", "5_QORIKALIS_06_08_2024.csv",
#'                 "6_QORIKALIS_12_11_2024.csv", "7_QORIKALIS_24_02_2025.csv", "8_QORIKALIS_22_06_2025.csv", "9_QORIKALIS_07_07_2025.csv",
#'                 "10_QORIKALIS_18_08_2025.csv"),
#'  ID = "QK", DATE_COLUMN = "Date_raw", DROP_IMPORT_COLUMNS_QK = c("Total: Regen, mm", "Total: Lluvia, mm"), DROP_COLUMNS_FINAL = c("Record", "Date_raw", "Dew_point"))
#' }
#' @param timezone character string. Containing the timezone in which the sensor data is recorded. 
#' Must be a valid Olson timezone name.
#' @examples
#' \dontrun{
#' Examples are:
#' TIMEZONE_DATA <- "America/Lima"
#' TIMEZONE_PROCESS <- "Europe/Berlin"}
#'
#' @return Data frame containing standardized meteorological observations. File and station-level identifiers are added.
#'
#' @author  Kai Albert zwießler
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
        required_columns = names(COLUMN_RENAME_MAP_QK) # uses the information from column rename map for this step.
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