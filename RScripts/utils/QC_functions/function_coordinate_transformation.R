#=================================================================================================================
# Scriptname: function_coordinate_transformation.R
# Goal(s):
  # Converting coordinates from UTM Zone 19S (EPSG:32719) -> World Geodetic System 1984 (WGS84 - EPSG:4326)
  # safing the result as a dataframe with two columns
# Author: Kai Albert Zwießler
# Date: 2025.11.20
# Input Dataset: //
# Outputs: //
# Units: //

#=================================================================================================================



#==============================================================
# UNIVERSAL FUNCTION: UTM DATAFRAME →> LAT/LON DATAFRAME
#==============================================================

utm_to_latlon <- function(df, x_col, y_col, zone, hemisphere = "south") {
  
  
  # Validate input objects
  if (!is.data.frame(df)) {
    stop("Argument 'df' must be a data.frame")
  }
  
  if (!all(c(x_col, y_col) %in% names(df))) {
    stop("Specified x_col or y_col not found in dataframe.")
  }
  
  
  # Determine EPSG code (UTM north/south logic)
  if (hemisphere == "south") {
    epsg_code <- 32700 + zone
  } else if (hemisphere == "north") {
    epsg_code <- 32600 + zone
  } else {
    stop("Hemisphere must be 'north' or 'south'.")
  }
  
 
  # Build sf object from dataframe
  sf_obj <- sf::st_as_sf(
    df,
    coords = c(x_col, y_col),
    crs = epsg_code
  )
  

  # Transform to WGS84 (EPSG 4326)
  sf_wgs <- sf::st_transform(sf_obj, crs = 4326)
  
  # Extract transformed coordinates
  coords <- sf::st_coordinates(sf_wgs)
  
  # Build final output dataframe
  result <- data.frame(
    df[ , !(names(df) %in% c(x_col, y_col)) ],  # keep all non-coordinate cols (e.g., Device)
    lat = coords[, "Y"],
    lon = coords[, "X"]
  )
  
  return(result)
}
