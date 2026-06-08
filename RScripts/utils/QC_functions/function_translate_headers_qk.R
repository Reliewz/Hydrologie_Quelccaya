#======================================================================
# Scriptname: utils/function_translate_spanish_headers_qk.R
# Function name: translate_spanish_headers_qk
# Goal(s):
  # Translate spanish column names to german column names

# Author: Kai Albert Zwießler
# Date: 2026.06.08
  # Input:  character vector containing spanish column names
  # Output: character vector with german column names
#======================================================================

#' @param x character vector containing column names
#' @param translation_map named character vector containing the old spanish column names and the desired german column names. 
#' Defined in the configuration file in the following order: "spanish_name" = "german_name".
#' @return character vector with translated column names
#' @export

translate_headers_qk <- function(x, translation_map = NULL)
   {
  
    # Input Validation
    if (!is.character(x)) stop("`x` must be a character vector.")
    if (is.null(translation_map)) stop("translation_map must be specified.")
    if (!is.character(translation_map)) stop("'translation_map' must be a character vector.") # Character string validation



  x[x %in% names(translation_map)] <-
    translation_map[x[x %in% names(translation_map)]]
  

# Final validation
message("Translated columns. Current column names: ", paste(x, collapse = ", "))

return(x)  
}