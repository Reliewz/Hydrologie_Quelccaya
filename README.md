# Semi-Automatic, Generic Quality Control Pipeline for Hydrometeorological Data

A modular R-based quality control pipeline designed for processing and validating hydrometeorological time series data. The pipeline automates common QC tasks while providing transparent outputs for user validation at each step. For in depth information also see (utils/QC_functions) to access the ROXYGEN 2 Documentation of each individual function. 

## Pipeline Architecture

The pipeline consists of **two specialized workflows**:
- **Meteorological Data Pipeline**: Optimized for weather station data (temperature, precipitation, radiation, etc.)
- **Hydrological Data Pipeline**: Tailored for discharge, water level, and related measurements

Both pipelines are **orchestrated by master scripts** that coordinate all processing steps in the correct sequence.

### Key Design Features

- **Externalized Configuration**: All settings (file paths, QC thresholds, column mappings) are managed through separate configuration files
- **Automatic Dependency Management**: Required R packages are loaded during the configuration step
- **Modular Architecture**: Each QC step is independent and generates intermediate outputs which is the input of the next QC step
- **Self-Contained**: All custom functions are included in the `util/` directory - no external dependencies beyond R packages
- **Debug Mode**: Built-in debugging feature that:
  - Saves intermediate data files (`.rds` format) after each processing step using `safe.rds()`
  - Reports exactly which pipeline step encountered an error
  - Enables rapid troubleshooting because of the modular architecture without re-running the entire pipeline
- **Customizable flag assignment**: After extracting the rows that have to be flagged , assign flags in three different modes:
  - `stop` (Default)
  - `overwrite` new flag assigment will be chosen, old ones will be removed
  - `combine` Both flags will be kept and combined into one column. seperated by ","
Note: The QC level parameter provides the information in which qc_level the flags will be applied. - QC_level will be then used to create a new column with the name of the QC level.
- **Customizable Documentation**: Built-in Flagging function with three modes:
  - `initial_assignment`: First-time flag assignment
  - `reclassification`: Updating existing flags
  - `manual_documentation`: User-defined documentation steps

## Features

### Current Implementation (v0.1.0-dev)

- **Standardizing date format**: YYYY-MM-DD hh:mm:ss according to international ISO guidelines
- **Sort mechanism**: builds packages according to ID columns and internally sorts by date column 
- **Temporal Continuity Check**: Validates continuous time steps in datetime columns
  - Three functions help to visually examine the data set (see functions)
- **Optional Info Line Extraction**: Uses entries in information columns (maintenance notes, sensors disconnections, sensor failures) to find maintenance patterns when measurement values are assigned "NA")
  - Identifies neighboring rows with NA values in data columns
  - Enables targeted flagging
- **QC Level 1 - Outlier Detection**:
  - **Range Test**: Identifies values outside physically plausible bounds
  - **Persistence Test**: Detects unnaturally constant values over time (duplicates)


### Functions
See util/QC_functions to access the ROXYGEN 2 documentation for each individual function.

### Upcomming Features

- Additional outlier tests (spike detection, rate-of-change)
- Modular, automated report generation
- Possibility to use CSV (.csv) data
- Zenodo integration to create a citable DOI for the software
- Outsourcing of QC level and flag value configuration
- Outsourcing of the Debug mode into the config file

## Installation

```r
# Clone the repository
git clone https://github.com/Reliewz/Hydrologie_Quelccaya.git
cd Hydrologie_Quelccaya

# Dependencies are automatically loaded during the configuration step
# No manual package installation required
```

### Input Data Requirements

- **Format**: Excel files (`.xlsx`)
- **Structure**: Time series data with datetime column, id column (if more devices are in one dataset) and value columns. Optional information columns to spot patterns.
- **Encoding**: UTF-8 recommended

## Quick Start

### For Meteorological Data

```r
# 1. Configure your settings in the config file
# Edit: 00_configuration/00_config_meteo.R (paths, thresholds, column names)

# 2. Run the master script
source("master_clean_data_meteo.R")

# Optional: Enable debug mode for troubleshooting
# Set KEEP_INTERMEDIATE = TRUE in the master script for debugging mode
# This will save intermediate files and report error locations

# The pipeline will:
# - Load dependencies automatically
# - Process your data through all QC steps
# - Generate outputs for each step
```

### For Hydrological Data

```r
# 1. Configure your settings
# Edit: 00_configuration/00_config_hydro.R

# 2. Run the master script
source("master_clean_data_hydro.R")
```

### Configuration Example

```r
# In your config file, specify:
# - Input/output file paths
# - QC thresholds (e.g., valid temperature range: -50 to 50°C)
# - Column mappings (which columns contain datetime, values, info columns etc.)
# - Possible values for QC level
```

### Outputs

The pipeline generates:

1. **QC Flags**: Quality control flags for each data point
   - Flags indicate which QC tests failed (e.g., out of range, persistent values)
   - **Important**: The pipeline does NOT automatically remove data - you decide which flagged data to keep or remove
   
2. **Log Files**: Detailed documentation of all QC operations performed, exported in a CSV File

3. **Intermediate Files** (debug mode): `.rds` files for troubleshooting

### Customization

**Documentation Function**: You can customize the built-in documentation function to match your naming conventions:
- Modify flag names (e.g., "outlier" vs "suspicious")
- Adjust documentation modes for your workflow
- Edit in `util/QC_functions/function_log_qc_flags.R`

## Why "Semi-Automatic"?

The pipeline balances automation with user oversight through its master script orchestration:
- The **master script coordinates** all QC steps automatically in the correct sequence
- Each step generates **intermediate outputs** that you can inspect
- **Configuration files** let you control thresholds and settings without editing code
- Users can **validate** the individual QC steps with printed outputs
- Dependencies are **loaded automatically** - no manual setup needed

This design ensures reproducibility while maintaining transparency, which is critical in research contexts.

## Use Cases

This pipeline is designed for:
- Research Organisations who require hydrometeorological time series data of high quality
- Meteorological stations, hydrological sensor with automated sensors prone to technical issues
- Studies needing documented, reproducible quality control procedures

## Project Status

🚧 **Active Development** - Currently in early alpha (v0.1.0-dev)

This pipeline is being developed for a bachelor thesis project which was part of research on modelling glacier contribution from the Quelccaya Ice Cap region on the basis of hydrometeorological data and a semi-distributed HBV model approach.


## Citation

This pipeline is made to contribute to better transparency in the hydrological field and is free to use. It runs under the LICENCE Apache 2.0
If you use this software in your research, please cite it to support continued development and help others discover this tool.

```bibtex
@software{Zwiessler_QC_Pipeline_2026,
  author = {Zwießler, Kai},
  title = {Semi-Automatic, Generic Quality Control Pipeline for Hydrometeorological Data},
  year = {2026},
  Independent Researcher  
  ORCID: [0009-0005-0756-1067](https://orcid.org/0009-0005-0756-1067)
  url = {https://github.com/Reliewz/Hydrologie_Quelccaya},
  version = {0.1.0-dev}
}
```

For detailed citation information in multiple formats, click the **"Cite this repository"** button in the sidebar or check out the CITATION file.


## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

This permissive license allows you to:
- Use the software for any purpose, including commercial applications
- Modify and distribute the software
- Use it in academic research without restriction


---

**Questions or suggestions?** Open an issue or reach out via GitHub or via E-Mail: zwiessler.kai@web.de