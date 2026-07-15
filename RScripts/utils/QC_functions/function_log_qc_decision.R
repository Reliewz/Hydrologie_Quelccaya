#======================================================================
# Script name: function_log_qc_decision.R
# Function name: log_qc_decision()
# Goal(s): 
  # With this parsimonious function the user creates documentation of initial assignments, reclassification of QC flags and manual review or documentation of QC decisions.
  # User is obligated to enter a flag value in case of Reclassification or initial_assignments.
  # The functions documents the number of flagged values for initial assignments and reclassification.

# Flagging Log - Quality Control - Good Practices, Reproducibility
# Author: Kai Albert Zwießler
# Date: 2025.12.16
#======================================================================

#' @title Function for documentation and archiving of QC test results and associated QC flags to guarantee reproducible workflows.
#' 
#' 
#' Can also be used or for the documentation of reproducible decision making important workflow related decisions to ensure reproducible workflows. 
#' 
#' Mostly in relation to QC flagging.
#' initial assignments or reclassifying  and/or important decisions throughout different
#'  process steps to guarantee reproducible workflows.
#'
#' @description The function contains relevant parameters for QC related documentation.
#' But can also be used for documentation purposes not associated with QC flags or threshold values.
#' 
#' Different selection possibilities of the \code{action} parameter enable the operator to make a selection according to the project status and requirements.
#' With the \code{initital_assignment} possibility it is made clear that this is the first QC with this data set.
#' With the \code{reclassification} possibility already tested and archived data can be re-evaluated under changed conditions. Former assigned flag values can be
#' exchanged for new flag assignments.
#' With the \code{manual_documentation} Documentation possibility not related to QC test results. Use cases can be peer reviews, expert evaluation, visual inspections 
#' 
#' @details The time and date will be automatically generated when the log entry is generated. Default timezone: Europe/Berlin
#' In case a \code{df} is provided the function also provides information about the total number of rows.
#' #' The \code{reason} is usually filled with contextual information and one of the most important documentation assets.
#' 
#' @param df Optional: Data frame, tibble or object that contains the detected rows.
#' If provided, summary information (e.g. number of affected rows) is derived automatically.
#' If NULL, the QC step is documented without direct relation to data input.
#' @param process_step Character string. Documentation requirement. The operator has to enter the working step in which the generated documentation log is generated. 
#' Examples include "range_test", "data_harmonization" or "expert_review".
#' @param operator Character string. The name of the contact person or the organisation which executed the quality control procedure.
#' @param device character string or character vector. Enables the operator to clearly define which devices or data sheets have been suspect to the
#' quality control procedure.
#' @param action Description of the action determining which documentation workflow will be executed.
#'  \describe{
#'      \item {initial_assignment}{Primary assignment of a QC flags for this data set}
#'      \item {reclassification}{Reclassification of an existing QC-flag-value, into a new flag category.}
#'      \item {manual_documentation}{Documentation of a QC decisions not based on a data frame input. This option can occur in (e.g. peer reviews, 
#'      expert evaluation, visual inspections or process steps not associated with flagging workflows).}}
#' @param from_flag Character string. Contains the previously assigned flag value. 
#' Only required for the \code{reclassification} workflow. Default: NULL.
#' @param to_flag Character string. Main flag assignment parameter. Contains the now assigned flag value for the \code{initial assignment} or 
#' after a \code{reclassification} workflow.
#' Must be NULL when action = "manual_documentation" is chosen.
#' @param qc_threshold Named list. Contains the selected threshold(s) for the respective QC tests.
#' @param tz Timezone used for time stamp generation (IANA format, e.g. "Europe/Berlin" on default)
#' @param reason Provides contextual background information to understand the reasoning behind the process step and associated decisions.
#' 
#' @author Kai Albert Zwießler
#' @return Returns a one-row tibble documenting a single QC decision. 
#' The returned object does not contain the data itself, only metadata. 
#' 
#' @seealso The function works best when integrated into a workflow with the following function:
#' \code{\link{apply_qc_flags}} to assign the respective QC flags to a data frame.



log_qc_decision <- function(
  df = NULL,
  process_step = NULL,
  operator,
  device,
  action,
  from_flag = NULL,
  to_flag = NULL,
  qc_threshold = NULL,
  reason,
  tz = "Europe/Berlin") {

# === STEP 1 ===

# General validation
# allowed actions and customized message
allowed_actions <- c(
  "initial_assignment",
  "reclassification",
  "manual_documentation"
)

if (length(action) != 1 || !action %in% allowed_actions) {
  stop(
    "Invalid action specified.\n",
    "Allowed values for the action parameter are:\n",
    paste(allowed_actions, collapse = ", ")
  )
}

  # pipeline stage documentation context
if (is.null(process_step)) {
  stop(
    "process_step must be specified.\n",
    "This parameter documents the process step in which the QC decision occurred."
  )
}
  
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
      stop("For action = 'initial_assignment' the parameter to_flag needs to be specified. (e.g. 'REVIEW', 'DELETE', 'VALID', 'IMPLAUSIBLE' (...)")
    }
    # case, when reason is not assigned any value
    if (is.null(reason)){
      stop("Documentation error: Good practice examples in QC workflows suggest a specification for the flag assignment. Please enter an explanation to the 'reason' parameter.")
    }
    if (is.null(qc_threshold)){
      warning("Absence of Threshold parameter: Please verify that the added flag information does not descent from a quality control tests using a threshold parameter.\n", "If a threshold parameter is associated please specifiy the qc_threshold parameter. ")
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
      stop("Documentation error: Good practice examples in QC workflows suggest a explaination, when a reclassification in the QC Step  occurs.\n Please enter an explanation to the 'reason' parameter.")
    }
    if (is.null(qc_threshold)){
      warning("Absence of Threshold parameter: Please verify that the added flag information does not descent from a quality control tests using a threshold parameter.\n", "If a threshold parameter is associated please specifiy the qc_threshold parameter. ")
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
      stop("Documentation error: Good practice examples in QC workflows suggest a specification for every QC Step. Please enter an explanation describing the design-decision taken to the 'reason' parameter.")
    }
    if (is.null(qc_threshold)){
      message("Note that no threshold value is provided in this documentation step. If the documentation step is associated with a documented QC test the repeated documentation of the QC threshold value with the 'qc_threshold' parameter is highly suggested.")
    }
  }


# === STEP 2: Return logic for documentation output ===

# establish the framework for a tibble where the information will be stored

# time stamp retrieval
timestamp <- format(
  Sys.time(),
  "%Y-%m-%d %H:%M:%S",
  tz = tz
)

if (action %in% c("initial_assignment", "reclassification")){
# nrow retrieval
nrows_value <- nrow(df)

qc_log <- tibble::tibble(
  timestamp = timestamp,
  action = action,
  process_step = process_step,
  operator = operator,
  device = device,
  from_flag = from_flag,
  to_flag = to_flag,
  qc_threshold = qc_threshold,
  reason = reason,
  n_flagged = nrows_value
)} else {
  qc_log <- tibble::tibble(
    timestamp = timestamp,
    action = action,
    process_step = process_step,
    operator = operator,
    device = device,
    from_flag = from_flag,
    to_flag = to_flag,
    qc_threshold = qc_threshold,
    reason = reason,
    n_flagged = NA_integer_
  )
  }

return(qc_log)
}