#=================================================================================================================
# Script name: coordinate_transformation.R
# Goal(s): 
# Author: Kai Albert Zwießler
# Date: 2025.12.24
# Input Dataset: 
# Outputs: 
# figures/
#=================================================================================================================

# Library

library(sf)
library(dplyr)

# Coordinate data: Piezometer + BAROM
utm_coords_pz <- data.frame(Device = c(paste0("PZ", sprintf("%02d", 1:12)), "BAROM"),
                            x = c(299184.3993, 299279.3782, 299475.9968, 299601.0980, 299607.1613, 
                                  299479.9303, 299432.1672, 299302.1533, 299168.8984, 299240.7638, 
                                  299053.4642, 299322.6926, 298822.5337),
                            y = c(8463245.9423, 8463168.2165, 8463142.1306, 8463205.7897, 8463323.1859, 
                                  8463313.4492, 8463202.6988, 8463294.1563, 8463376.2507, 8463452.2814, 
                                  8463383.1424, 8463376.6515, 8463357.8907))


# Coordinate transformation from UTM Zone 19s to WGS84
cat("Step 3: Coordinate transformation. UTM Zone 19S to WGS84")
wgs_coords_pz <- utm_to_latlon(
  df = utm_coords_pz,
  x_col = "x",
  y_col = "y",
  zone = 19,
  hemisphere = "south"
)


# Coordinate data: WLS + BAROM
utm_coords_wls <- data.frame(Device = c("WLS_L", "WLS_O", "BAROM"),
                             x = c(300467.4405, 297097.5124, 298822.5337),
                             y = c(8462061.4462, 8463168.4825, 8463357.8907))

# Coordinate transformation from UTM Zone 19s to WGS84
wgs_coords_wls <- utm_to_latlon(
  df = utm_coords_wls,
  x_col = "x",
  y_col = "y",
  zone = 19,
  hemisphere = "south"
)