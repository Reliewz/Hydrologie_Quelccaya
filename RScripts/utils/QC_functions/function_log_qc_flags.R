#======================================================================
# Script name: utils/QC_functions/function_log_qc_flags.R
# Function name: log_qc_flags()
# Goal(s): 
  # With this parsimonious function the user creates documentation of assignments and reclassifications of QC flags.
  # User is obligated to enter a flag value in case of Reclassification or initial_assignments.

# Flagging Log - Quality Control - Good Practices, Reproducibility
# Author: Kai Albert Zwießler
# Date: 2025.12.16


#' function name: log_qc_flags()
#' The function provides a framework for reproducible documentation of changes according to flags in the quality control phase.
#' 
#' # ========== CONFIGURATION ==========
#' @param df Optional: Data frame, tibble or object that contains the affected rows.
#' If provided, summary information (e.g. number of affected rows) is derived automatically.
#' If NULL, the QC step is documented without direct relation to data input.
#' @param action Description of the QC action that is documented.
#'  \describe{
#'      \item {initial_assignment}{Primary assignment of a QC flag based on a data frame}
#'      \item {reclassification}{Reclassification of an existing QC-flag-value, into a new flag category.}
#'      \item {manual_documentation}{Documentation of a QC decision without direct data frame input this can occure in (e.g. peer review, expert evaluation or visual inspections) without resulting in a change of flags.}}
#' @param from_flag Contains the previous flag declaration. Only required for reclassification purposes. Default: NULL (used for initial assignments and manual documentation)
#' @param to_flag Contains the flag declaration after a reclassification or a first assignment.
#' Must be NULL when action = "manual_documentation" is chosen.
#' @param tz Timezone used for time stamp generation (IANA format, e.g. "Europe/Berlin" on default)
#' @param reason Provides contextual background information to understand the reasoning behind the process step
#' @return Returns a one-row tibble documenting a single QC decision. 
#' The returned object does not contain the data itself, only metadata. 
#' A time stamp is automatically generated with function call time.
#' NOTE: Step count is derived externally when combining multiple log entries



log_qc_flags <- function(
  df = NULL,
  action = c("initial_assignment", "reclassification", "manual_documentation"),
  from_flag = NULL,
  to_flag,
  reason,
  tz = "Europe/Berlin") {

# === STEP 1 ===
# Input validation for declared action
action <- match.arg(action) #match.arg matches a character against a table of values.
  
  # Input validation in context to declared action
  # initial_assignment
  if (action  == "initial_assignment"){
    # Case, no data frame is assigned.
    if (is.null(df) ){
      stop("A data frame needs to be assigned for action = 'initial assignment'.")
    }
    # case, from_flag has an entry
    if (!is.null(from_flag)){
      stop("For action = 'initial_assignment' the value from flag must contain no value.")
    }
    # case, to_flag is not assigned a value
    if (is.null(to_flag)){
      stop("For action = 'initial_assignment' an argument needs to be delivered to the parameter to_flag (f.e. 'REVIEW', 'DELETE', 'VALID', 'IMPLAUSIBLE' (...)")
    }
    # case, when reason is not assigned any value
    if (is.null(reason)){
      stop("Documentation error: Good practice examples in QC workflows suggest a specification for the flag assignment. Please enter an explaination in the 'reason' parameter.")
    }
    }
  
  # Input validation in context to declared action
  # reclassification
  if (action  == "reclassification"){
    # Case, no data frame is assigned.
    if (is.null(df) ){
      stop("A data frame needs to be assigned for action = 'reclassification'.")
    }
    # case, from_flag has no entry
    if (is.null(from_flag)){
      stop("For action = 'reclassification' the name of the original flag-value needs to be documented.")
    }
    # case, to_flag is not assigned a value
    if (is.null(to_flag)){
      stop("For action = 'reclassification' an argument needs to be delivered to the parameter to_flag (f.e. 'REVIEW', 'DELETE', 'VALID', 'IMPLAUSIBLE' (...)")
    }
    # case, when reason is not assigned any value
    if (is.null(reason)){
      stop("Documentation error: Good practice examples in QC workflows suggest a explaination, when a reclassification in the QC Step  occurs.\n Please enter an explaination in the 'reason' parameter.")
    }
  }
  
  # Input validation in context to declared action
  # manual_documentation
  if (action  == "manual_documentation"){
    # Case, a data frame is assigned.
    if (!is.null(df) ){
      stop("For action = 'manual_documentation' a data frame is not required.\n
           If a data frame is part of the QC step, please check the options: 'initital_assignment or 'reflassification'.")
    }
    # case, from_flag has an entry
    if (!is.null(from_flag)){
      stop("For action = 'manual_documentation' the value from_flag must contain no value.")
    }
    # case, to_flag is not assigned a value
    if (!is.null(to_flag)){
      stop("For action = 'manual_documentation' the value to_flag must contain no value.\n
           For Flag assignments check other options: 'initital_assignment or 'reflassification'.")
    }
    # case, when reason is not assigned any value
    if (is.null(reason)){
      stop("Documentation error: Good practice examples in QC workflows suggest a specification for every QC Step. Please enter an explaination in the 'reason' parameter.")
    }
  }


# === STEP 2: Return logic for documentation output ===

# establish the framework for a tibble where the information will be stored

# time stamp retrieval
timestamp <- as.POSIXct(Sys.time(), tz = tz)

if (action %in% c("initial_assignment", "reclassification")){
# nrow retrieval
nrows_value <- nrow(df)

qc_log <- tibble::tibble(
  timestamp = timestamp,
  action = action,
  from_flag = from_flag,
  to_flag = to_flag,
  reason = reason,
  nrows = nrows_value
)} else {
  qc_log <- tibble::tibble(
    timestamp = timestamp,
    action = action,
    from_flag = from_flag,
    to_flag = to_flag,
    reason = reason,
    nrows = NA_integer_
  )
  }
}