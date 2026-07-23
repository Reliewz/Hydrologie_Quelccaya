#======================================================================
# Scriptname: function_apply_qc_flags.R
# Function name: apply_qc_flags()
# Goal(s): 
  # The function assigns QC flags to the data frame: data_raw_flagged
  # The user has to decide which flag name needs to be applied. dshould be transported into the assigned column. data_raw_flagged$Flags. To keep it generic the following string, at the beginning of the script, has been assigned:   qc_column <- "temporal_consistency, duplicates (...)"
  # Existing QC flags will be kept untouched. If a conflict in the merging column exists the function stops and prints the conflict row.
  # If the data set contains more than one measurement devices, an id_column needs to be assigned to add an additional distinguish logic to only the merge_col. Reflected in a group_by mechanism and a arrange mechanism
# Date: 2025.12.08
#======================================================================

#' @title Function for customizable QC flag assignments
#' 
#' 
#' @description 
#' The function uses a Left Outer Join mechanism, using the information stored in a data frame specified in \code{df_flag_info} and applies them
#' to a master data frame \code{df}. This is done by generating a new column, which name is dictated by the value provided to \code{qc_test} in which
#' customizable quality control flags using \code{flag_value} can be assigned.
#'
#' @details 
#' Safety restriction and security precautions have to be taken into consideration:
#' 
#' 1. The safety restriction: To successfully use \code{apply_qc_flags} the operator has to define which QC tests will be applied on his data beforehand.
#' This step is implemented to provide full control to the operator when the function is applied in a pipeline setting. 
#' Additionally, it prevents typing errors for the column creation workflow, as each flagging-result of the executed QC tests are stored in a individual column.
#' The value specified in \code{qc_test} is used as the name for the generation of the new column and has to match one of the vectors 
#' specified in \code{ALLOWED_QC_TESTS}.
#' This is done by creating a variable named \code{ALLOWED_QC_TESTS} in the global environment containing a character vector with the 
#' names of the QC tests.
#' @example ALLOWED_QC_TESTS <- c("completeness_test", "gross_error_check")
#' 
#' 2. The security precaution: The function uses a \code{semi_join} mechanism before the actual join (Left Outer Join) is executed.
#' This is used to detect preliminary conflicts and prevent undesired merge-outputs.
#' If such an error is detected the operator can resolve them using a \code{conflict_mode} selection or resolve the problem manually.
#' 
#'
#' @note
#' This function can be used as the second step of the three step comprehensive QC workflow. QC Test execution -> Flag assignment -> Documentation
#' 1. Execution of the respective QC test
#' 2. The generated result can then be used to assign the QC flags using \code{\link{apply_qc_flags}}
#' 3. Creating a log file entry, containing valuable information about the process (e.g. used QC threshold, number of flagged rows (...)) and the framework in which
#' the test has been executed (e.g. Operator name, embedded process step, additional explanation of the results). using the function \code{\link{log_qc_decision}}
#' @seealso
#' \code{\link{apply_qc_flags}} to assign the respective QC flags using the generated \code{$data} from the individual QC tests.
#' \code{\link{log_qc_decisions}} to generate a log file containing valuable information about the process and framework conditions.
#' 
#' 
#' @param df the data frame or tibble where the QC flags will be applied to.
#' @param flag_value customizable parameter where the user can assign a flag name (e.g. "VALID", "INVALID", "SUSPICIOUS" (...)).
#' @param qc_test Character string. Provides the name for the column generation in which the QC flags will be stored. - all QC tests 
#' cause the generation of a separate column in which the respective flags is stored.
#' A reasonable nomenclature connects the QC test (e.g. "completeness_test", "gross_error_check" (...)) with the associated flags.
#' Important: The specified name for \code{qc_test} has to match with one of the character-values stored inside the variable \code{ALLOWED_QC_FLAGS} defined in 
#' the global environment.
#' 
#' @param merge_col character string. Column used as "matching key", as a link between the original data frame \code{df} and the data frame 
#' containing the flag information \code{df_flag_info}.
#' Advice: In time series applications the column containing date and time information is suitable.
#' If working with a master data frame where different sensors are separated by ID a specification using \code{id_col} covers that case.
#' 
#' @param df_flag_info data frame. Contains the rows where at least one values did not pass the executed QC test. 
#' The rows defined provide the information which rows will be flagged in \code{df}.
#' 
#' @param id_col (optional) character string. Column name of a master data frame containing a clear identifier.
#' Used for cases when multiple measurement devices with equal time frames are concatenated in a master data frame.
#' When supplied, records are matched using the combination of id_col and merge_col.
#' @param sort Logical. If "TRUE", data will be sorted before flag application.
#' Sorting is performed for human readability and workflow consistency only. Therefore, it does not affect join operations.
#' Default: FALSE to prevent a unwanted change of a predefined sorting logic defined by the operator.
#' If \code{id_col} is provided, sorting is performed by \code{id_col} (e.g. Sensor ID) and \code{merge_col} (e.g. date column)
#' Otherwise sorting is performed by \code{merge_col} only.
#' 
#' @param conflict_mode in case of a merging conflict. Which is the case when identical columns overlap and a QC flag value is already assigned to a specific records.
#' The operator has different options to solve this issue: 
#'  \describe{
#'    \code{stop}{Default setting for good practice. The user can solve the conflict manually or re-run the function by selecting a proper conflict_mode}
#'    \code{overwrite}{Option 1: The new flag assignments will be chosen old ones will be removed.}
#'    \code{combine}{Both flags will be kept and combined into one column. separated by ","}
#'  }
#'  
#' @return tibble or data frame containing the flag information inside the QC test-related column.
#' 
#' @author Kai Albert Zwießler
#'
#' #' @references
#' WMO, 2011:  Chapter 3 - CLIMATE DATA MANAGEMENT Page 8
#' Guide to Climatological Practices (WMO-No. 100), Third Edition. ed.
#' World Meteorological Organization, Geneva, Switzerland.
#' 
#' Manola et al. 2020: Page 50
#' Best Practice Guidelines for Climate Data and Metadata Formatting,
#' Quality Control and Submission. https://doi.org/10.24381/KCTK-8J22
#' @export

apply_qc_flags <- function(
  df,
  flag_value = NULL,
  qc_test = NULL,
  df_flag_info,
  merge_col,
  id_col = NULL,
  sort = FALSE,
  conflict_mode = c("stop", "overwrite", "combine")
  ) {
  # ===== Input validation =====
  if (!is.data.frame(df)) {
    stop("df must be a data frame or tibble")
  }

  if (!is.data.frame(df_flag_info)) {
    stop("df_flag_info must be a data frame or tibble")
  }

  if (!is.null(id_col)) {
    if (!id_col %in% names(df)) {
      stop("id_col '", id_col, "' does not exist in df.")
    }

    if (!id_col %in% names(df_flag_info)) {
      stop("id_col '", id_col, "' does not exist in df_flag_info.")
    }
  }

  if (!merge_col %in% names(df)) {
    stop(
      "The merge column, where both data frames contain identical information, need to be assigned. This serves as a connection to merge the wanted information"
    )
  }
  if (!merge_col %in% names(df_flag_info)) {
    stop(
      "The merge column, where both data frames contain identical information, need to be assigned. This serves as a connection to merge the wanted information"
    )
  }

  if (!identical(class(df[[merge_col]]), class(df_flag_info[[merge_col]]))) {
    warning(
      "merge_col '",
      merge_col,
      "' has different data types:\n",
      "  df: ",
      paste(class(df[[merge_col]]), collapse = ", "),
      "\n",
      "  df_flag_info: ",
      paste(class(df_flag_info[[merge_col]]), collapse = ", ")
    )
  }

  # User must assign a flag value
  if (is.null(flag_value)) {
    stop(
      "flag_value must be specified (e.g., 'DELETE', 'REVIEW', 'SUSPECT', 'VERIFIED')"
    )
  }

  # Pipeline validation - Check if ALLOWED_QC_TESTS is defined in global environment
  if (!exists("ALLOWED_QC_TESTS")) {
    stop(
      "ALLOWED_QC_TESTS must be defined in the global environment.\n",
      "Example: ALLOWED_QC_TESTS <- c('GROSS_ERROR_CHECK', 'PERSISTENCE_TEST', (...))."
    )
  }

  # Additional validation: ALLOWED_QC_TESTS should not be NULL or empty
  if (is.null(ALLOWED_QC_TESTS) || length(ALLOWED_QC_TESTS) == 0) {
    stop(
      "ALLOWED_QC_TESTS exists but is empty. Please provide a character vector containing the executed QC tests."
    )
  }

  # User must assign a QC tests
  if (is.null(qc_test)) {
    stop(
      "qc_test must be specified.\n",
      "Allowed values: ",
      paste(ALLOWED_QC_TESTS, collapse = ", ")
    )
  }

  # input validation of QC tests from ALLOWED_QC_TESTS in the configuration file
  qc_test <- match.arg(qc_test, choices = ALLOWED_QC_TESTS)
  # input validation of choice of conflict mode. match.arg allows only the table of strings set in the function.
  conflict_mode <- match.arg(conflict_mode)

  # ==== SYMBOL conversion =====
  # converting the parameter qc_test to symbol
  qc_column <- rlang::sym(qc_test)
  # conversion of strings with characters, containing column information, to symbols.
  merge_column <- rlang::sym(merge_col)
  # only convert id_col to a symbol when not 0. Converting 0 into a symbol results in an error.
  if (!is.null(id_col)) {
    id_column <- rlang::sym(id_col)
  }

  # Missing id column
  if (is.null(id_col)) {
    warning(
      "No id_column specified. Matching will be performed using merge_col only!\n",
      "If multiple measurement devices exist in a data frame and also share identical merge_column values, ",
      "this may result in a flag assignment to unintended records."
    )
  }
  # ==== COLUMN CREATION ====
  # Assignment of an output column where flags will be applied to. If no column exist in the selected data frame it will be created
  # Create "qc test" column if it doesn't exist
  if (!qc_test %in% names(df)) {
    message("Creating new QC column: '", qc_test, "'.")
    df <- df %>%
      mutate(!!qc_column := NA_character_)
  }

  # Check if existing column is type character
  if (!is.character(df[[qc_test]])) {
    warning(
      "QC column '",
      qc_test,
      "' is not of type character. Coercing to character."
    )
    df[[qc_test]] <- as.character(df[[qc_test]])
  }
  
  # When extracting form a list
  if (is.list(df_flag_info) && !is.data.frame(df_flag_info)) {
    stop(
      "df_flag_info appears to be a list. Please extract a single data frame first (e.g., df_flag_info$below15)"
    )
  }

  # Application of sort - logic.
  if (sort) {
    if (!is.null(id_col)) {
      df <- df %>%
        arrange(!!id_column, !!merge_column)

      df_flag_info <- df_flag_info %>%
        arrange(!!id_column, !!merge_column)
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

  # validation if df_flag_info contains any rows
  if (nrow(flag_info) == 0) {
    message(
      "No rows to flag in df_flag_info. Returning original data unchanged."
    )
    return(df)
  }

  # Workflow execution if more sensors exist in the same data frame and an id_column is assigned.:
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

    col_existing <- paste0(qc_test, ".existing")
    col_new <- paste0(qc_test, ".new")

    # Extract and display conflicting rows with both values
    conflict_preview <- preview %>%
      filter(!is.na(!!sym(col_existing)) & !is.na(!!sym(col_new))) %>%
      select(all_of(join_cols), !!sym(col_existing), !!sym(col_new))

    warning(
      "Conflict detected ",
      nrow(conflict_preview),
      " rows in QC test column '",
      qc_test,
      "':",
      "Showing existing vs. new flag values:",
      "Set a conflict_mode = 'overwrite' or 'combine' to proceed, or resolve the merging problem manually."
    )
    print(conflict_preview)

    # Check conflict_mode FIRST before any data modification
    if (conflict_mode == "stop") {
      stop(
        "Flag assignment conflict detected in QC test column '",
        qc_test,
        "'.\n",
        nrow(conflict_preview),
        " row(s) would be reclassified.\n",
        "Conflicting values shown above.\n",
        "Original data remains unchanged.\n",
        "Set conflict_mode = 'overwrite' or 'combine' to proceed."
      )
    }

    # Handle conflicts based on user choice
    if (conflict_mode == "overwrite") {
      message(
        "Applying conflict_mode = 'overwrite': New flags will replace existing ones."
      )
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

    message(
      "✓ Successfully resolved conflicts: applied ",
      sum(!is.na(preview[[col_new]])),
      " flags to column '",
      qc_test,
      "' using '",
      conflict_mode,
      "' mode"
    )
  } else {
    # add information back to full data frame and cleaning of columns NO CONFLICT CASE
    # ===================================================================
    # NO CONFLICT BRANCH
    # All rows to be flagged should have NA in the QC column
    # ===================================================================

    # Create preview of the join
    preview <- df %>%
      left_join(flag_info, by = join_cols, suffix = c(".existing", ".new"))

    # Define temporary column names
    col_existing <- paste0(qc_test, ".existing")
    col_new <- paste0(qc_test, ".new")

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
        "QC workflow aborted: ",
        nrow(both_present),
        " row(s) would be reclassified silently.\n",
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

    message(
      "✓ Successfully applied ",
      sum(!is.na(preview[[col_new]])),
      " flags to column '",
      qc_test,
      "'"
    )
  }
  return(df)
}
