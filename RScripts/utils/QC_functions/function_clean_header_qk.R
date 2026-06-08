#======================================================================
# Scriptname: utils/function_clean_headers_qk.R
# Function name: clean_headers_qk ()
# Goal(s):
  # Remove logger and sensor metadata from meteorological column names

# Author: Kai Albert Zwießler
# Date: 2026.06.06
# Input:  character vector containing column names
# Output: character vector without meta data
#======================================================================

#' @param x character vector containing column names
#' @return character vector without meta data
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