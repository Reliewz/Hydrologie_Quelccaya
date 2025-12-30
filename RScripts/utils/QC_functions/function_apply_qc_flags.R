#======================================================================
# Scriptname: utils/QC_functions/function_apply_qc_flags.R
# Function name: apply_qc_flags()
# Goal(s): 
  # The function assigns QC flags to the data frame: data_raw_flagged
  # The user has to decide which flag name needs to be applied. dshould be transported into the assigned column. data_raw_flagged$Flags. To keep it generic the following string, at the beginning of the script, has been assigned:   qc_column <- "temporal_consistency, duplicates (...)"
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
#' @param qc_level the parameter connection the information in which qc_level the flags will be applied. - will be used as column name
#' @param merge_col the column who serves as a link between the data frame and flag_info to perform joins, to merge the information.
#' @param df_flag_info second data frame which contains the flag information that later will be joined with df
#' @param id_col (optional) if the data set contains more than one measurement device. This column adds a group_by logic to apply the logic to one device before going to the next
#' @param sort=TRUE default value "TRUE" the function will sort the dataset with the following logic: if a id_col is assigned group by id_col, if a merge_col is assigned arrange by merge_col afterwards. If sort = false no sorting mechanism is carried out, a warning message will be displayed that the user has to sort before applying the function.
#' @param conflict_mode in case of a merging conflict (overlapping of QC flags) the user decides how to handle it 
#'  \describe{
#'    \item{stop}{default setting for good practice methods. The user has to solve the conflict manually or set a conflict_mode}
#'    \item{overwrite}{The new flags assigment will be chosen old ones will be removed}
#'    \item{combine}{Both flags will be kept and combined into one column. seperated by ","}
#'  }
#' @return tibble or dataframe where the new assigned flags will be safed into the previous arranged and i nthe function assigned column

apply_qc_flags <- function(
    df,
    flag_value = NULL,
    qc_level = NULL,
    df_flag_info,
    merge_col,
    id_col = NULL,
    sort = TRUE,
    conflict_mode = c("stop", "overwrite", "combine")
    ) {
  
 # ===== Input validation =====
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

  if (!identical(class(df[[merge_col]]), class(df_flag_info[[merge_col]]))) {
    warning(
      "merge_col '", merge_col, "' has different data types:\n",
      "  df: ", paste(class(df[[merge_col]]), collapse = ", "), "\n",
      "  df_flag_info: ", paste(class(df_flag_info[[merge_col]]), collapse = ", ")
    )
  }

# User must assign a flag value
if (is.null(flag_value)) {
  stop("flag_value must be specified (e.g., 'DELETE', 'REVIEW', 'SUSPECT', 'VERIFIED')")
}

# User must assign a QC level
  if (is.null(qc_level)) {
    stop(
      "qc_level must be specified.\n",
      "Allowed values: ", paste(QC_LEVELS, collapse = ", ")
    )
  }
# User assignment of global QC_LEVEL options
  if (is.null(QC_LEVELS)){
    stop("Choices of QC Levels must be assigned in the global environment.")
  }
  
# input validation of qc-levels from QC_LEVELS
qc_level <- match.arg(qc_level, choices = QC_LEVELS)  
# input validation of choice of conflict mode. match.arg allows only the table of strings set in the function.
conflict_mode <- match.arg(conflict_mode)

# ==== SYMBOL CONVERTION =====
# converting the parameter qc_level to symbol
qc_column <- rlang::sym(qc_level)
# Convertion of strings with characters, containing column information, to symbols.
merge_column <- rlang::sym(merge_col)
# only convert id_col to a symbol when not 0. Converting 0 into a symbol results in an error.
if (!is.null(id_col)) {
  id_column <- rlang::sym(id_col)
} 

# Missing id column
if (is.null(id_col)) {
  warning("The function assumes that only one measurement device exists. No group_by mechanism or measurment device distinction is applied.")
}
# ==== COLUMN CREATION ====
# Assignment of an output column where flags will be applied to. If no column exist in the selected data frame it will be created
# Create QC level column if it doesn't exist
if (!qc_level %in% names(df)) {
  message("Creating new QC column: '", qc_level, "' (initialized with NA).")
  df <- df %>%
    mutate(!!qc_column := NA_character_)
}

# Check if existing column is type character
if (!is.character(df[[qc_level]])) {
  warning("QC column '", qc_level,  "' is not of type character. Coercing to character.")
  df[[qc_level]] <- as.character(df[[qc_level]])
}
  
# Sort function
if (!sort) {
  warning("no sorting mechanism is carried out. Good practice examples suggest to always organize the data before appling operational steps.")
}

# When extracting form a list
if (is.list(df_flag_info) && !is.data.frame(df_flag_info)) {
  stop("df_flag_info appears to be a list. Please extract a single data frame first (e.g., df_flag_info$below15)")
}



# Function body for sort - logic
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
  mutate(!!qc_column := flag_value)

# Workflow according to id_column:
if (!is.null(id_col)) {
  join_cols <- c(id_col, merge_col)        
} else {
  join_cols <- merge_col                   
  }

# Mechanism to identify a merge conflict: overlapping. isolating flagged values from original data frame
# Extract which rows match.
matched_rows <- df %>%
  semi_join(flag_info, by = join_cols)

# Filter What rows already contain QC values
conflict_rows <- matched_rows %>%
  filter(!is.na(!!qc_column))

# If conflicts exist
if (nrow(conflict_rows) > 0) {
  # Create preview to analyze conflicts
  preview <- df %>% 
    left_join(flag_info, by = join_cols, suffix = c(".existing", ".new"))
  
  col_existing <- paste0(qc_level, ".existing")
  col_new <- paste0(qc_level, ".new")
  
  # Extract and display conflicting rows with both values
  conflict_preview <- preview %>%
    filter(!is.na(!!sym(col_existing)) & !is.na(!!sym(col_new))) %>%
    select(all_of(join_cols), !!sym(col_existing), !!sym(col_new))
  
  message("Conflict detected in ", nrow(conflict_preview), " rows for QC level '", qc_level, "':")
  message("Showing existing vs. new flag values:")
  message("Set conflict_mode = 'overwrite', 'combine' to proceed, or 'stop' to resolve manually.")
  print(conflict_preview)
  
  # Check conflict_mode FIRST before any data modification
  if (conflict_mode == "stop") {
    stop(
      "Flag assignment conflict detected in QC level '", qc_level, "'.\n",
      nrow(conflict_preview), " row(s) would be reclassified.\n",
      "Conflicting values shown above.\n",
      "Original data remains unchanged.\n",
      "Set conflict_mode = 'overwrite' or 'combine' to proceed."
    )
  }
  
  # Handle conflicts based on user choice
  if (conflict_mode == "overwrite") {
    message("Applying conflict_mode = 'overwrite': New flags will replace existing ones.")
    df <- preview %>%
      mutate(!!qc_column := !!sym(col_new)) %>%
      select(-all_of(c(col_existing, col_new)))
  }
  
  if (conflict_mode == "combine") {
    message("Applying conflict_mode = 'combine': Flags will be combined.")
    df <- preview %>%
      mutate(
        !!qc_column := case_when(
          !is.na(!!sym(col_existing)) & !is.na(!!sym(col_new)) ~ 
            paste(!!sym(col_existing), !!sym(col_new), sep = ", "),
          !is.na(!!sym(col_new)) ~ !!sym(col_new),
          TRUE ~ !!sym(col_existing)
        )
      ) %>%
      select(-all_of(c(col_existing, col_new)))
  }
  
  message("Successfully resolved conflicts: applied ", sum(!is.na(preview[[col_new]])), 
          " flags to QC level '", qc_level, "' using '", conflict_mode, "' mode")
 }
  # add information back to full data frame and cleaning of columns NO CONFLICT CASE
 else {
  # ===================================================================
  # NO CONFLICT BRANCH
  # All rows to be flagged should have NA in the QC column
  # ===================================================================
  
  # Create preview of the join
  preview <- df %>% 
    left_join(flag_info, by = join_cols, suffix = c(".existing", ".new"))
  
  # Define temporary column names
  col_existing <- paste0(qc_level, ".existing")
  col_new <- paste0(qc_level, ".new")
  
  # SAFETY ASSERTION: Verify no unexpected conflicts
  # This checks if conflict detection worked correctly
  both_present <- preview %>%
    filter(!is.na(!!sym(col_existing)) & !is.na(!!sym(col_new)))
  
  if (nrow(both_present) > 0) {
    # Critical error detected - abort function without changing df
    message("CRITICAL ERROR: Unexpected conflict in no-conflict branch!")
    message("The following rows have both existing flags:")
    print(
      both_present %>% 
        select(all_of(join_cols), !!sym(col_existing), !!sym(col_new))
    )
    
    stop(
      "QC workflow aborted: ", nrow(both_present), " row(s) would be reclassified silently.\n",
      "Original data remains unchanged.\n",
      "This indicates a logic error in conflict detection.\n",
      "Please report this bug with the error details above."
    )
  }
  
  # replacing the NA values with flag values (coalesce)
  df <- preview %>%
    mutate(
      !!qc_column := coalesce(!!sym(col_new), !!sym(col_existing))
    ) %>%
    select(-all_of(c(col_existing, col_new)))
  
  message("Successfully applied ", sum(!is.na(preview[[col_new]])), 
          " flags to QC level '", qc_level, "'")
 }
return(df)
}
