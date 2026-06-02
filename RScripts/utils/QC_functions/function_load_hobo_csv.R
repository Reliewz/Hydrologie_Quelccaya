#======================================================================
# Scriptname: utils/function_load_hobo_csv.R
# Function name: load_hobo_csv
# Goal(s): 
  # Folder import function for .csv data (Default: pressure sensor HOBO U20L
  # Csv import, skip function to skip stored metadata
  # imports all .csv files stored in a folder
  # A new column called "Date" is generated, where the type is converted to POSIXct format and automatically to ISO 8601 YYYY.MM.DD hh:mm:ss.
  # the function informs via message about date format for validation
# Author: Kai Albert Zwießler
# Outputs:
  # integrated data, without duplicates and converted date column

#======================================================================

#' # ========== CONFIGURATION ==========
#' @param folder_path the file path where all the data of this sensor is stored
#' @param keep_files Character vector of filenames to import. If NULL, all .csv files in folder_path are imported.
#' @param date_col the original name of the date column, later should be renamed
#' @param timezone timezone in which the sensor data is recorded
#' @param skip amount of the skipped rows when importing. Default = 1 as this works for the HOBO U20L and can be adjusted depending on amount of rows containing metadata before the actual headlines begin. 
#' @return tibble
#' @export
#' 

load_hobo_csv <- function(folder_path, 
                          keep_files = NULL,
                          date_col = NULL,
                          timezone = NULL,
                          skip = 1
                          ){
  
  
# Input validation
  if (!dir.exists(folder_path)) stop(sprintf("folder_path '%s' not found. A proper path needs to be assigned for data access.", folder_path)) # %s variable for strings
  
  
  if (is.null(date_col)) stop("The original name of the date column is not assigned. This prevents a later applied date conversion step.")
# Warning messages according to type of input data
  if (is.null(keep_files)) message("All .csv fils inside the folder will be imported.")
  if (is.null(timezone)) stop("timezone must be specified. Example: 'America/Lima', 'Europe/Berlin'. See OlsonNames() for all valid options.")
  if (!timezone %in% OlsonNames()) stop(sprintf("'%s' is not a valid timezone. See OlsonNames() for valid options.", timezone))
  if (!is.numeric(skip)) stop("skip must be a number.")
  
  
# String to symbol transformation
date_column_sym <- rlang::sym(date_col)


# 1. Folder import with map_dfr concatenate function
extract_all_paths <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE) # regex syntax \. to interprate "." as "." not a arbitrary sign and \\ to interprate \ as "\".
if (length(extract_all_paths) == 0) stop("No .csv files found in folder_path.")

datapaths_named <- setNames(
  extract_all_paths,
  basename(extract_all_paths))

  
# validation step if assigned keep_files and folder files match 1:1
  if (!is.null(keep_files)){
    not_found <- keep_files[!keep_files %in% names(datapaths_named)]
    if (length(not_found) > 0) {
      warning(sprintf("Files not found in folder: %s", paste(not_found, collapse = ", ")))
    }
    # filtering according to keep_files for input
    datapaths_named <- datapaths_named[names(datapaths_named) %in% keep_files]
  }

# validation step if no files exist after filtering procedure
if (length(datapaths_named) == 0) stop("No files remaining after applying keep_files filter.")


data_raw <- purrr::map_dfr(
  .x = datapaths_named,
  # \(x) to apply the read.csv function to every file selected or to every file in the folder.
  .f = \(x) read.csv(x, skip = skip, colClasses = "character"),
  .id = "Source.Code"
)
 

# Date conversion to POSIXct type
data_raw <- data_raw %>%
  mutate(
    Date = parse_date_time(
      x = !!date_column_sym,
      orders = c("ymd HMS", "dmy HMS", "mdy HMS", 
                 "mdy HMS p", "ymd HM", "dmy HM"),
      tz = timezone
    )
  )
 
# Sort mechanism according to Date column
data_raw <- data_raw %>%
  arrange(Date)

# check if any parsing error occurred
n_na <- sum(is.na(data_raw$Date))
if (n_na > 0) {
  warning(sprintf("%d NA values in Date column after conversion.", n_na)) #%d for integers
} else {
  message("✓ Date conversion successful. No NA values.")
}
  
# final output validation
# Informative output
message("First date: ", format(head(data_raw$Date, 1)))
message("Last date: ",  format(tail(data_raw$Date, 1)))
message("Total rows: ", nrow(data_raw))

return(tibble::as_tibble(data_raw))
}