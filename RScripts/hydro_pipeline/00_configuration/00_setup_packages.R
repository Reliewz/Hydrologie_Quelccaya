#### PACKAGES ####
required_packages <- c(
  "dplyr",      # Data manipulation
  "tidyr",      # Data structure
  "lubridate",  # Date handling
  "readxl",     # Excel import
  "stringr",    # String extraction (Piezometer ID)
  "naniar",     # NA data examination
  "gtExtras"    # Easy tables
)

# Install missing packages
new_packages <- required_packages[!required_packages %in% installed.packages()[,"Package"]]
if(length(new_packages)) install.packages(new_packages)

# Load all packages quietly
invisible(lapply(required_packages, library, character.only = TRUE))

#### GLOBAL OPTIONS ####
options(stringsAsFactors = FALSE)
options(dplyr.summarise.inform = FALSE)
options(pillar.neg = FALSE)  # Nice NA display