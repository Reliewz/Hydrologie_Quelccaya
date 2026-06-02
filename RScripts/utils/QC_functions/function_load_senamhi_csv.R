#======================================================================
# Scriptname: utils/function_load_senamhi_csv.R
# Function name: load_senamhi_csv
# Goal(s): 
  # Folder import function for .csv data
  # integrated skip function to skip stored metadata
  # imports column types as characters to prevent differences in column typees among the .csv files
# Author: Kai Albert Zwießler
# Outputs:
  # tibble containing alls files concatinated with bind_rows() and column types as character format.

#======================================================================

#' # ========== CONFIGURATION ==========
#' @param folder_path the file path where all the data of the meteorlogical station is stored
#' @param keep_files Character vector of filenames to import. If NULL, all .csv files in folder_path are imported.
#' @param skip amount of the skipped rows when importing. Default = 5 as this works for the SENAMHI data structre and can be adjusted depending on amount of rows containing metadata before the actual headlines begin. 
#' @return tibble
#' @export

load_senamhi_csv <- function(folder_path, 
                          keep_files = NULL,
                          skip = 5
){
  
  
  # Input validation
  if (!dir.exists(folder_path)) stop(sprintf("folder_path '%s' not found. A proper path needs to be assigned for data access.", folder_path)) # %s variable for strings
  
  # Warning messages according to type of input data
  if (is.null(keep_files)) message("All .csv fils inside the folder will be imported.")
  if (!is.numeric(skip)) stop("skip must be a number.")
  

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
  
  return(tibble::as_tibble(data_raw))
}