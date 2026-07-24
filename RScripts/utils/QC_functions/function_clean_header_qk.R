#======================================================================
# Script name: function_clean_headers_qk.R
# Function name: clean_headers_qk ()
# Date: 2026.06.06
#======================================================================
#' @title Function to remove metadata for the Qori-Kalis meteorological station
#' 
#' @note specified function especially for the metadata of this individual station.
#'  
#' @param x character vector. Containing the names of the column where the function is applied to.
#' @return character vector without meta data
#' @author Kai Albert zwießler
#' @export

clean_headers_qk <- function(x){
  
  x <- gsub(
    "\\s*\\(.*\\)$",
    "",
    x
  )
  
  x <- trimws(x)
  
  return(x)
}