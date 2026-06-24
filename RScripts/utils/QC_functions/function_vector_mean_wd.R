#======================================================================
# Scriptname: utils/function_vector_mean_wd.R
# Function name: vector_mean_wd
# Goal(s): 
  # Helps to aggregate the wind direction column with vector mean instead of arithmetic mean
  # Does a quick internal consistency check if win direction records are in a plausible range 0° - 360°
  # excludes NA values as they can negatively impact the aggregation process
# Author: Kai Albert Zwießler
# Date: 2026.06.24
#======================================================================

#' Compute the vector mean of wind direction
#'
#' Aggregates wind direction values in degrees using circular vector averaging.
#' Each direction is decomposed into its east-west (sine) and north-south
#' (cosine) unit vector components. The components are averaged separately and
#' the mean angle is reconstructed via \code{atan2}. This avoids the wraparound
#' error of arithmetic means (e.g., 350 and 10 degrees averaging to 180 instead
#' of 0 degrees).
#'
#' \code{NA} values are excluded before computation. If all values in \code{x}
#' are \code{NA}, the function returns \code{NA_real_}.
#'
#' @param x Numeric vector of wind direction values in degrees (0 to 360).
#'
#' @return A single numeric value representing the circular mean wind direction
#'   in degrees (0 to 360), or \code{NA_real_} if no valid values are present.
#'
#' @seealso \code{\link{aggregate_15min_to_hourly}} which applies this function during
#'   temporal aggregation workflows based on the configuration file
#'
#' @export


vector_mean_wd <- function(x) {
  
  # Input validation
  if (!is.numeric(x)) {
    stop("`x` must be a numeric vector of wind direction values in degrees (0 to 360).")
  }
  
  x <- x[!is.na(x)]
  
  if (length(x) == 0) return(NA_real_)
  
  # Range validation — out-of-range values indicate a data quality issue
  # that must be resolved before aggregation, as errors may become
  # invisible after averaging.
  if (any(x < 0 | x > 360)) {
    stop(
      paste(
        "`x` contains values outside the valid range [0, 360].",
        "Resolve data quality issues before aggregation."
      )
    )
  }
  
  u <- mean(sin(x * pi / 180)) # east-west component
  v <- mean(cos(x * pi / 180)) # north-south component
  wd <- atan2(u, v) * 180 / pi # reconstruct angle from mean vector
  
  return((wd + 360) %% 360)    # map to [0, 360]
}