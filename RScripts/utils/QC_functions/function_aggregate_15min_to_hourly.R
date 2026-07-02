#======================================================================
# Script name: utils/function_aggregate_15min_to_hourly.R
# Function name: aggregate_15min_to_hourly
# Goal(s): 
  # aggregate 15 minute time steps to hourly time steps
  # inform the user for required dependencies and other functions required for specific variables
  # informs the user when more columns are defined in the configuration than existing in the data frame
  # informs the user if deviations with the number of available records used for the aggregation exist

# Author: Kai Albert Zwießler
# Date: 2026.06.24
# Output:
# Returns a named list with two elements:
# $data — master data frame with aggregated files substituted for their
#          15-minute predecessors. Non-aggregated files remain unchanged.
#          Column structure and order are identical to the input data frame.
# $coverage_problems — data frame documenting all hours where temporal
#                      coverage deviates from the expected 4 values per hour.
#                      Empty if no coverage issues were detected.
# Dependencies:
# vector_mean_wd() — required for wind direction aggregation if WD is
#                    defined in agg_config. Must be loaded before this function.
#======================================================================

#' Aggregate 15-minute meteorological or hydrological time series to hourly values
#'
#' Aggregates 15-minute interval time series data to hourly values for one or
#' more specified files within a master data frame. Each file is extracted by a
#' unique identifier, aggregated independently, and substituted back into the
#' master data frame. Aggregation functions are defined per variable in a named
#' configuration list. Wind direction variables are supported via circular vector
#' averaging using function \code{\link{vector_mean_wd}}.
#' Custom functions such as \code{vector_mean_wd} must be loaded in the
#' environment before calling this function.
#'
#' The function evaluates temporal coverage per variable per hour. Hours where
#' the number of valid (non-NA) measurement values falls below the
#' \code{min_coverage} threshold are set to \code{NA} and reported in the
#' returned \code{coverage_problems} data frame. Hours where more valid values
#' than expected are detected cause the function to stop, as this indicates a
#' deviation from the expected 15-minute time step.
#'
#' @note Character columns (e.g. event flags from HOBO loggers during
#'   maintenance events) are not supported by standard aggregation functions.
#'   It is recommended to resolve or remove such columns prior to aggregation
#'   using a completeness check.
#' @param df A data frame or tibble containing the master data frame with
#'   15-minute interval time series data. Must contain all columns defined in
#'   \code{agg_config}, the \code{date_column}, and the \code{source_column}.
#'
#' @param agg_config A fully named list defining the aggregation function per
#'   variable. Names must match column names in \code{df}. Values must be
#'   character strings matching the exact function name (e.g. \code{"mean"},
#'   \code{"sum"}, \code{"max"}, \code{"vector_mean_wd"}) or function objects.

#'
#' @param date_column A single character string specifying the name of the
#'   date and time column in \code{df}. Must be of class \code{POSIXct}.
#'   Timestamps are floored to the full hour during aggregation.
#'
#' @param source_column A single character string specifying the name of the
#'   column in \code{df} that contains the file identifiers (e.g.
#'   \code{"Source.Code"}). Used to extract individual files from the master
#'   data frame for aggregation.
#'
#' @param source_id A character string or character vector specifying one or
#'   more file identifiers to aggregate. Values must match entries in
#'   \code{source_column}. Each file is aggregated independently and
#'   substituted back into the master data frame.
#'
#' @param min_coverage A single numeric value between 0 and 1 defining the
#'   minimum proportion of valid (non-NA) measurement values required per hour
#'   to perform the aggregation. For 15-minute data, one hour contains 4
#'   values. A \code{min_coverage} of 0.5 requires at least 2 valid values.
#'   Hours below or equal to this threshold are reported to the operator. Defaults to
#'   \code{0.5}.
#' @return A named list with two elements:
#'   \describe{
#'     \item{\code{data}}{A data frame or tibble containing the updated master
#'       data frame. Aggregated files are substituted for their 15-minute
#'       predecessors. Non-aggregated files remain unchanged. Column structure
#'       and column order are identical to the input \code{df}.}
#'     \item{\code{coverage_problems}}{A data frame documenting all hours where
#'       temporal coverage deviates from the expected 4 values per hour. Contains
#'       the following columns: the date column, \code{variable} (affected
#'       variable name), \code{n_measurement_values} (number of valid values
#'       available), \code{n_total_rows_per_hour} (total rows in the hour
#'       including NA rows), \code{coverage_pct} (percentage of expected values
#'       available), and \code{issue} (description of the detected problem).
#'       Returns an empty data frame if no coverage issues were detected.}
#'   }
#'
#' @seealso \code{\link{vector_mean_wd}} for the circular vector averaging
#'   function used for wind direction aggregation.
#'
#' @export

aggregate_15min_to_hourly <- function(
    df,
    agg_config,
    date_column,
    source_column = NULL,
    source_id    = NULL,
    min_coverage = 0.5) {
  
  # --- Input validation ---------------------------------------------------
  
  if (!is.data.frame(df)) {
    stop("`df` must be a data.frame or tibble.")
  }
  
  # validation for configuration file
  if (is.null(agg_config)) {
    stop("`agg_config` must be specified. Define aggregation functions per variable in the configuration file in the following manner:",
         "column name = aggregation code e.g. mean, max, vector_mean.")
  }
  
  if (!is.list(agg_config) || is.null(names(agg_config))) {
    stop("`agg_config` must be a named list.")
  }
  # If the list is properly adjusted, according to the configuration scheme column_name = aggregation function
  if (is.null(names(agg_config)) || any(names(agg_config) == "")) {
    stop("`agg_config` must be a fully named list with no empty names.")
  }
  
  # date column validation
  if (is.null(date_column)) {
    stop("The name of the `date_column` must be specified as a character string.")
  }
  # date_column character & vector validation
  if (!is.character(date_column) || length(date_column) != 1) {
    stop("`date_column` must be a single character string not a character vector.")
  }
  
  if (!date_column %in% names(df)) {
    stop(paste("`date_column`", date_column, "not found in `df`."))
  }
  
  if (!inherits(df[[date_column]], "POSIXct")) {
    stop(paste("Column", date_column, "must be of class POSIXct before this action can be performed."))
  }
  
  # source_column and source_id
  if (is.null(source_column)) {
    stop("`source_column` must be specified. Please specify the column in which the `source_id` information can be found.")
  }
    
  if (!is.character(source_column)) {
    stop("`source_column` must be a character string or NULL.")
  }
  if (length(source_column) != 1) {
    stop("`source_column` must be a single character string. Please ")
  }
  if (!source_column %in% names(df)) {
    stop(paste0("`source_column` '", source_column, "' not found in `df`."))
  }
  
  
  if (is.null(source_id)) {
    stop("`source_id` must be specified. Please specify the files that shall be aggregated to hourly time step.")
  }
    
  if (!is.character(source_id)) {
    stop("`source_id` must be a character string or character vector.")
  }

  # source_id values exist in source_column
  missing_ids <- source_id[!source_id %in% df[[source_column]]]
  if (length(missing_ids) > 0) {
    stop(paste0(
      "The following `source_id` values were not found in provided source_column. '",
      source_column, "': ",
      paste(missing_ids, collapse = ", "), "."
    ))
  }
  
  # min_coverage
  if (!is.numeric(min_coverage) || length(min_coverage) != 1) {
    stop("`min_coverage` must be single numeric value between 0 and 1.")
  }
  if (min_coverage < 0 || min_coverage > 1) {
    stop("`min_coverage` must be a value between 0 and 1.")
  }

  # columns in agg_config must be present in df
  missing_cols <- setdiff(names(agg_config), names(df))
    if (length(missing_cols) > 0) {
      stop(paste0(
        "The following columns are defined in `agg_config` but missing in `df`: ",
        paste(missing_cols, collapse = ", "), "."
      ))
    }

  # aggregation function strings must be resolvable - validation if dependencies of the functions (e.g. vector_mean for wind direction) is loaded into the environment.
  valid_funs <- sapply(names(agg_config), function(col) { # takes the column names of the config and stores the information in the col control variable
    fun_name <- agg_config[[col]] # stores the associated aggregation function (e.g mean, max or vector_mean) and stores it in fun_name for the next step
    if (!is.character(fun_name)) return(TRUE) # function object pass through and are correctly resolved - implemented logic for later package implementation
    # allows to provide function objects instead of a character vector in a configuration file
    tryCatch({ # try catch aggregates and stores the error message that return FALSE for a united output which variables weren't able to be resolved.
      # it helps so that the loop does not stop.
      match.fun(fun_name) # in case of a FALSE return and a function object was not able to be resolved
      TRUE # was able to be resolved, returns TRUE
    }, error = function(e) FALSE) # could not be resolved, returns FALSE
  })
  if (any(!valid_funs)) {
    stop(paste0(
      "The following aggregation functions could not be resolved: ",
      paste(names(agg_config)[!valid_funs], collapse = ", "), ". ",
      "Ensure that all custom functions (f.e. function_vector_mean_wd) are loaded in the environment before calling aggregate_15min_to_hourly()."
    ))
  }
  
  # --- Data extraction ----------------------------------------------------
  # set expected number of values inside one hour. 4 expected aggregation contributors derived from 15 minute time steps in one hour
  n_expected <- 4L  # 60 min / 15 min = 4 expected values per hour. L makes it a integer
  
  
  df_aggregated_list <- purrr::map(source_id, \(id) { 
      # extract subset (rows) for this source_id
       rows_to_extract <- df[[source_column]] == id # the column content of source_column is evaluated with [[]] and compared with the given source_id and stored in       the object. Provides logical vector
       df_target       <- df[rows_to_extract, ] # finally the rows who match the previous logical condition (TRUE) are stored in df_target.
      
    
      #--- Temporal flooring
      # time stamps are floored to the full hour to ensure compatibility with
      # other hourly time series and to enable correct grouping during aggregation.
      df_target[[date_column]] <- lubridate::floor_date(
        df_target[[date_column]],
        unit = "hour"
      )
      # identify non-aggregated columns for restore mechanism. provides the columns without content
      non_agg_cols <- setdiff(
        names(df_target),
        c(names(agg_config), date_column)
      )
      # --- Aggregation --------------------------------------------------------
      # group by floored time stamp
      
      hourly_groups <- df_target %>%
        dplyr::group_by(.data[[date_column]]) # .data is used to call a column inside the data frame in the dplyr logic
      
      # coverage check for number of values available for the aggregation to hourly values
      # --- Coverage log -------------------------------------------------------
      # computes the number of valid (non-NA) values per variable per hour.
      # used to identify hours where aggregation is based on fewer values
      # than expected and to warn the user accordingly.
      
      coverage_log <- hourly_groups %>%
        dplyr::summarise(
          dplyr::across(
            .cols = names(agg_config),
            .fns  = \(col_values) sum(!is.na(col_values)) # counts all rows that have measurement values. later renamed to n_measurement_values
          ),
          .groups = "drop"
        )
      
      # identify hours below min_coverage threshold or above expected values
      coverage_problems <- coverage_log %>%
        tidyr::pivot_longer( # function to change the order of the data arrangement. Here variables are changed from columns to rows.
          cols      = names(agg_config), # only change the arrangement of the columns defined in the aggregation_config (measurement columns)
          names_to  = "variable", # the column name of the rearranged columns is set to variables.
          values_to = "n_measurement_values" # generates a new column with the name n_measurement_values, where the amount of values inside the measurement column information is stored.
        ) %>%
        dplyr::filter(
          n_measurement_values <= ceiling(min_coverage * n_expected) | # ceiling returns a rounded integer value. # | OR syntax
            # the number of measurement values per hour smaller than the min_coverage parameter
            n_measurement_values > n_expected # condition 2 differentiates among real measurement values. NA´s are not used in the comparison
          # more measurment values inside the hourly time step than expected with a 15 minute aggregation scheme
        ) %>%
        dplyr::mutate(
          coverage_pct = round(n_measurement_values / n_expected * 100, 1),
          issue = dplyr::case_when(
            n_measurement_values > n_expected ~ 
              paste0("The 15 min to hourly aggregation contains more valid measurement values ",
              "than expected. Expected: ", n_expected, "."), # ~ is used to connect condition and message. if true ~ then message
            n_measurement_values <= ceiling(min_coverage * n_expected) ~
              paste0("The number of available valid measurement values (", n_measurement_values, "),
              is below or equal to the min_coverage threshold. (", min_coverage * 100, "% = ", ceiling(min_coverage * n_expected),
                     " values)."
                     )
          )
        )
    
      # --- Coverage report ----------------------------------------------------
      
      if (nrow(coverage_problems) > 0) {
        warning(
          "aggregate_15min_to_hourly(): Temporal coverage issues detected for source_id '", id, "' in the aggregated time series. ",
          "Temporal coverage describes how many valid measurement values are available to execute the temporal aggregation from 15 min to hourly time steps.",
          "Inspect the coverage_problems data frame for more details.",
          call. = FALSE
        )
        print(coverage_problems)
      } 
      
      # Function stop in case of more values than expected
      # stop if more values than expected — must be resolved manually before aggregation
      extra_values <- coverage_problems %>%
        dplyr::filter(n_measurement_values > n_expected)
      
      if (nrow(extra_values) > 0) {
        stop(
          "aggregate_15min_to_hourly(): More valid measurement values than expected detected. ",
          "This indicates the input data may not be completely on a 15-minute interval. ",
          "Inspect coverage_problems, resolve the affected timestamps manually, and re-run the function.",
          call. = FALSE
        )
      }
      
      
      # --- Aggregation --------------------------------------------------------
      
      df_aggregated <- hourly_groups %>%
        dplyr::summarise(
          dplyr::across( # across to adresses all columns and enables us to provide a internal loop to the summarise function 
            .cols = names(agg_config),  # here in the first argument the columns are called with (names()) and assigned with .cols. Here it is defined
            # over which variable the aggregation shall take place.
            .fns  = \(col_values) { # here a small function is written instead of the usual operation required in summarise (mean, max etc)
              
              n_measurement_values <- sum(!is.na(col_values)) # recalculation inside the anonymous function
              coverage             <- n_measurement_values / n_expected
              
              fun <- match.fun(agg_config[[dplyr::cur_column()]]) # cur_column provides the column name of the configuration file agg_config
              # provides the aggregation operation (e.g mean (...)) and match.fun making it a functional object, stored in fun 
              # match.fun works here as the bridge between configuration file and the written function here in the script.
              
              if ("na.rm" %in% names(formals(fun))) { # checks if a parameter named "na.rm" exists in the function
                return(fun(col_values, na.rm = TRUE)) # this is mostly important for mathematical operations (mean, max etc.)
              } else { # working with an else argument as the utility function vector_mean_wd does not have this parameter
                return(fun(col_values)) # the function is then applied on the col_values operation variable
              }
            }
          ),
          .groups = "drop"
        )
      
        # restore non aggregated columns
      # --- restore mechanism for non-aggregated columns --------------------------------------------------------
      # Take first row from df_target from non aggregated columns
      constant_values <- df_target[1, non_agg_cols, drop = FALSE]
      constant_values <- constant_values[
        rep(1, nrow(df_aggregated)), , drop = FALSE
      ]
      rownames(constant_values) <- NULL
      df_aggregated <- dplyr::bind_cols(df_aggregated, constant_values)
      
      # restore original column order
      df_aggregated <- df_aggregated[, names(df_target)]
      
      return(list(
        data              = df_aggregated,
        coverage_problems = coverage_problems
      ))
      
      })
  
  # --- Combine aggregated files -------------------------------------------
  df_result <- dplyr::bind_rows(
    purrr::map(df_aggregated_list, "data")
  )

  coverage_all <- dplyr::bind_rows(
    purrr::map(df_aggregated_list, "coverage_problems")
  )
  
  # --- Substitute aggregated files in master df ---------------------------
  
  # remove original 15-min rows for the selected source_ids from master df
  rows_to_remove <- df[[source_column]] %in% source_id # contains the logical vector which rows will be later removed and susbtituted
  df_remaining   <- df[!rows_to_remove, ] # reverse logic, keeps all rows that weren't part of source id and therefore of the aggregation workflow
  
  # combine remaining rows with aggregated files
  df_result <- dplyr::bind_rows(df_remaining, df_result) # bind rows with df_remainaing (non aggregated rows) and df _result aggregated rows
  
  # restore original column order of master df
  df_result <- df_result[, names(df)]
  # create a list in the environment which shows the coverage problems
  return(list(
    data              = df_result, # contains the new master_df
    coverage_problems = coverage_all
  ))

}