#### PACKAGES ####
required_packages <- c(
  "dplyr",      # Data manipulation
  "slider",     # Data selection package, applying a function to all data (sliding window)
  "tidyr",      # Data structure
  "purrr",      # data import concatenate sensors and station data
  "lubridate",  # Date handling
  "readxl",     # Excel import
  "stringr",    # String extraction
  "gtExtras",   # Easy tables
  "rlang",      # Symbol conversion for functions
  "quarto",     # Creating reports of the results
  "here"        # Adjusting directories for usage in universal environments
)

# Install missing packages
new_packages <- required_packages[!required_packages %in% installed.packages()[,"Package"]]
if(length(new_packages)) install.packages(new_packages)

# Load all packages quietly
invisible(lapply(required_packages, library, character.only = TRUE)) # library() all relevant packages

#### GLOBAL OPTIONS ####
options(stringsAsFactors = FALSE)
options(dplyr.summarise.inform = FALSE)
options(pillar.neg = FALSE)  # Nice NA display