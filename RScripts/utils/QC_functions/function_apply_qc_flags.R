#======================================================================
# Scriptname: utils/function_apply_qc_flags.R
# Function name: apply_qc_flags()
# Goal(s): 
  # The function assigns QC flags to the data frame: data_raw_flagged
  # The user has to decide which flag name needs to be applied. dshould be transported into the assigned column. data_raw_flagged$Flags. To keep it generic the following string, at the beginning of the script, has been assigned:   apply_flags_column <- "Flags"
  # Existing QC flags will be kept untouched. If a conflict in the merging column exists the function stops and prints the conflict row.
  # If the dataset contains more than one measurment devices, an id_column needs to be assigned to add an additional distinguish logic to only the merge_col. Reflected in a group_by mechanism and a arrange mechanism

# Flagging - Quality Control Good Practices
# Author: Kai Albert Zwießler
# Date: 2025.12.08


#' function name: apply_qc_flags()
#' The function applies QC flags to an assigned data frame.
#' 
#' # ========== CONFIGURATION ==========
#' @param df the dataframe where the qc flags are supposed to be applied to
#' @param flag_value a parameter where the user has to assign a flag value f.e. "REVIEW", "DELETE" (...)
#' @param apply_flags_col the column where the flags will be applied to
#' @param merge_col the column who serves as a link between the dataframe and flag_info to perform joins, to merge the information
#' @param id_col (optional) if the data set contains more than one measurement device. This column adds a group_by logic to apply the logic to one device before going to the next
#' @param sort=TRUE default value "TRUE" the function will sort the dataset with the following logic: if a id_col is assigned group by id_col, if a merge_col is assigned arrange by merge_col afterwards. If sort = false no sorting mechanism is carried out, a warning message will be displayed that the user has to sort before applying the function.
#' @param
#' @return tibble or dataframe where the new assigned flags will be safed into the previous arranged and i nthe function assigned column

apply_qc_flags <- function(
    df,
    flag_value = NULL,
    flag_apply_col,
    merge_col,
    id_col = NA,
    sort = TRUE
    )
  
# Input validation
  if!(merge_col %in% names(df) & merge_col %in% names(flag_info), stop("The data frame and flag_info do not contain an identical column")) # Dangerous because flag_info might be hard coded. a second dataframe is required here - revise.

# User must assign a flag value
if (is.null(flag_value)) {
  stop("flag_value must be specified (e.g., 'DELETE', 'REVIEW', 'SUSPECT', 'VERIFIED')")
}
# Missing id column
if (id_col == Null) {
  warning("The function assumes that only one measurement device exists. No goup_by mechanism or measurment device distinction is applied.")
}

# Assignment of an output column where flags will be applied to.
if !(apply_flag_col %in% names(df) {
  stop("The data frame contains no column with flag information. A column where the flag information will be stored has to be assigned.")
}

# Sort function
if (sort == FALSE) {
  warning("no sorting mechanism is carried out. Good practice examples suggest to always organize the data before appling operational steps.")
}

# Convertion of strings with characters, containing column information, to symbols.
id_colum <- rlang::sym(!!id_col)
apply_flags_column <- rlang::sym(!!apply_flags_col)
merge_column <- rlang::sym(!!merge_col)
