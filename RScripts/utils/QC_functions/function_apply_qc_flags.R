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
#' @param merge_col the column who serves as a link between the data frame and flag_info to perform joins, to merge the information.
#' @param df_flag_info second data frame which contains the flag information that later will be joined with df
#' @param id_col (optional) if the data set contains more than one measurement device. This column adds a group_by logic to apply the logic to one device before going to the next
#' @param sort=TRUE default value "TRUE" the function will sort the dataset with the following logic: if a id_col is assigned group by id_col, if a merge_col is assigned arrange by merge_col afterwards. If sort = false no sorting mechanism is carried out, a warning message will be displayed that the user has to sort before applying the function.
#' 
#' @return tibble or dataframe where the new assigned flags will be safed into the previous arranged and i nthe function assigned column

apply_qc_flags <- function(
    df,
    flag_value = NULL,
    df_flag_info,
    apply_flags_col,
    merge_col,
    id_col = NULL,
    sort = TRUE
    )
  
# Input validation
if (!is.data.frame(df)) {
  stop("df must be a data frame or tibble")
  }
  
if (!is.data.frame(df_flag_info)) {
  stop("df_flag_info must be a data frame or tibble")
  }  
  
if (!merge_col %in% names(df)) {
  stop("The merge column, where both data frames contain identical information, need to be assigned. This serves as a connection to merge the wanted information")
  }
if (!merge_col %in% names(df_flag_info)) {
  stop("The merge column, where both data frames contain identical information, need to be assigned. This serves as a connection to merge the wanted information")
}

if (class(df[[merge_col]]) != class(df_flag_info[[merge_col]])) {
  warning("merge_col hat unterschiedliche Datentypen in df und df_flag_info!")
}

# User must assign a flag value
if (is.null(flag_value)) {
  stop("flag_value must be specified (e.g., 'DELETE', 'REVIEW', 'SUSPECT', 'VERIFIED')")
}
# Missing id column
if (is.null(id_col)) {
  warning("The function assumes that only one measurement device exists. No goup_by mechanism or measurment device distinction is applied.")
}

# Assignment of an output column where flags will be applied to.
if (!apply_flags_col %in% names(df)) {
  stop("The data frame contains no column with flag information. A column where the flag information will be stored has to be assigned.")
}

# Sort function
if (sort == FALSE) {
  warning("no sorting mechanism is carried out. Good practice examples suggest to always organize the data before appling operational steps.")
}

# When extracting form a list
if (is.list(df_flag_info) && !is.data.frame(df_flag_info)) {
  stop("df_flag_info appears to be a list. Please extract a single data frame first (e.g., df_flag_info$below15)")
}

# Convertion of strings with characters, containing column information, to symbols.
id_column <- rlang::sym(id_col)
apply_flags_column <- rlang::sym(apply_flags_col)
merge_column <- rlang::sym(merge_col)

# Functionbody for sort - logic
if (sort){
  if (!is.null(id_col)) {
    df <- df %>%
      group_by(!!id_column) %>%
      arrange(!!merge_column) %>%
      ungroup()
  
    df_flag_info <- df_flag_info %>%
      group_by(!!id_column) %>%
      arrange(!!merge_column) %>%
      ungroup()
 } else {
   df <- df %>% 
   arrange(!!merge_column)
   
   df_flag_info <- df_flag_info %>%
     arrange(!!merge_column)
 }
}


# execution of join-logic (left_join)
# Selection of the important columns for merge-process
if (!is.null(id_col)) {
flag_info <- df_flag_info %>%
  select(!!id_column, !!merge_column)
} else {
  flag_info <- df_flag_info %>%
    select(!!merge_column)
}

# create column flags and assign the user defined flag_value
flag_info <- flag_info %>%
  mutate(!!apply_flags_column := flag_value)




# Mechanism to identify a merge conflict: overlapping. isolating flagged values from original data frame
# Extract which rows match
matched_rows <- df %>%
  semi_join(flag_info, by = c(id_col, merge_col))

# What rows already contain QC values
conflict_rows <- matched_rows %>%
  filter(!is.na(!!apply_flags_column))

# If conflicts exist
if (nrow(conflict_rows) > 0) {
  message("Overlap conflict detected in the following rows")
  print(
    conflict_rows %>%
      select(all_of(c(id_col, merge_col)), !!apply_flags_column)
  )
  stop("Flag assignment conflict: Some rows already contain QC Flags Information.")
}





# Double flag assignment problem
if (df_flag_content == df_info_flag_content) {
  stop("Flag assignment conflict: The rows you want to merge already contain a value in the original df.")
}
  
# Add flag information back to the full dataset
if (!is.null(id_col)) {
  df <- df %>% 
  left_join(flag_info,
            by = c(id_col, merge_col))
} else {
  df <- df %>% 
    left_join(flag_info,
              by = c(merge_col))
}

