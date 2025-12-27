#=================================================================================================================
# Scriptname: function_coordinate_transformation.R
# Goal(s):
  # Converting coordinates between UTM and WGS84
# Author: Kai Albert Zwießler
# Date: 2025.12.26
# Output: data frame containing the coordinate infromation and device name.

#=================================================================================================================

#' function utm_latlon_transform
#' A function that converts coordinates from either utm to wgs or wgs to utm.
#' 
#' @param df a data frame that contains coordinates
#' @param y_col Column name for latitude (WGS84) or northing (UTM)
#' @param x_col Column name for longitude (WGS84) or easting (UTM)
#' @param convertion_mode
#'  \itemize{
#'  \item \code {"to_utm"} Convert WGS84 (lat/lon) to UTM = Default mode.
#'  \item \code {"to_wgs"} Convert UTM to WGS84 (lat/lon)
#'  }
#' @param zone assigns the correct zone for the hemisphere of interest.
#' @param hemisphere assigns if the coordinate system is in the northern part or southern part of the world
#' \itemize{
#' \item south for southern part
#' \item north for the northern part
#' }
#' @return Data frame with transformed coordinates and station name

#==============================================================
# UNIVERSAL FUNCTION: UTM  <→> LAT/LON transformation
#==============================================================

utm_latlon_transform <- function(
    df,
    y_col,
    x_col,
    convertion_mode = c("to_utm", "to_wgs"),
    zone, 
    hemisphere = c("south", "north")) {
  
  
  # Validate input objects
  convertion_mode <- match.arg(convertion_mode)
  hemisphere <- match.arg(hemisphere)
  
  if (!is.data.frame(df)) {
    stop("Argument 'df' must be a data.frame")
  }
  
  if (!all(c(x_col, y_col) %in% names(df))) {
    stop("Specified x_col or y_col not found in dataframe.")
  }
  # check if a zone is delivered
  if (is.null(zone)){
    stop("A zone needs to be assigned for your hemisphere possible values 1 to 60")
  }
  # check if zone is in a reasonable range
  if (!zone %in% 1:60){
    stop("Zone must be between 1 and 60")
  }

  
  # Determine EPSG code (UTM north/south logic)
  if (hemisphere == "south") {
    epsg_utm <- 32700 + zone
  } else {(hemisphere == "north")
    epsg_utm <- 32600 + zone
  }
  
  # Determine input and output CRS based on conversion mode
  if (convertion_mode == "to_wgs") {
    input_crs <- epsg_utm   # From UTM
    output_crs <- 4326      # To WGS84
  } else {  # "to_utm"
    input_crs <- 4326       # From WGS84
    output_crs <- epsg_utm  # To UTM
  }
  
  # Build sf object from dataframe
  sf_obj <- sf::st_as_sf(
    df,
    coords = c(x_col, y_col),
    crs = input_crs
  )
  # Transform to output CRS
  sf_transformed <- sf::st_transform(sf_obj, crs = output_crs)
  
  # Extract coordinates
  coords <- sf::st_coordinates(sf_transformed)

  
  # Build output dataframe with appropriate column names
  if (convertion_mode == "to_wgs") {
    result <- data.frame(
      df[, !(names(df) %in% c(x_col, y_col))],
      lat = coords[, "Y"],
      lon = coords[, "X"]
    )
  } else {  # "to_utm"
    result <- data.frame(
      df[, !(names(df) %in% c(x_col, y_col))],
      y = coords[, "Y"],
      x = coords[, "X"]
    )
  }
  
  return(result)
}
