# Hydrometeorological Quality Control Pipeline

A modular and reproducible framework for importing, harmonizing, quality-controlling, flagging and documenting hydrometeorological monitoring data.

The project was originally developed and tested as part of a glacio-hydrological modelling workflow within the hydrometeorological monitoring network of the Qori-Kalis catchment, Quelccaya Ice Cap (Peru), and is designed for broader use in environmental monitoring programs, NGOs, governmental agencies and applied research projects.

## Why this project?

Hydrometeorological monitoring networks often combine data from multiple sensors, manufacturers and file formats. Before these data can be used for scientific analyses, hydrological modelling or operational decision-making, they must be standardized, validated and documented.

While individual tools exist for specific quality control tasks, integrated and reproducible workflows for hydrometeorological data harmonization, quality control and documentation remain limited within the R ecosystem. A central objective of this project is to provide transparent and reproducible quality control workflows while preserving full traceability of all quality control decisions.

Beyond quality control, the framework supports reproducible data management by integrating data harmonization, quality assessment, flagging and audit documentation within a single environment.

Key components include:

* Data import and harmonization
* Temporal continuity assessment
* Quality control procedures
* Flexible QC flagging
* QC documentation and audit logging

## Current Features

### Data Import and Harmonization

Implemented utility functions support:

* Folder-based batch Imports for .csv data
* Automatic timestamp conversion according to ISO 8601
* Time zone handling
* Column harmonization
* Header cleaning
* Translation of station-specific headers
* Source file tracking
* Standardized output structures

Fully automatic and specialized import workflows are currently available for:

* INAIGEM automatic weather station data
* HOBO pressure loggers

### Temporal Continuity Assessment

Implemented temporal continuity tools include:

* Time-step calculation
* Gap detection
* Interval summarization
* Identification of temporal inconsistencies

These functions support the detection of missing observations, unexpected sampling intervals and temporal gaps.

### QC Flagging Framework

The framework follows a flagging-based approach. Observations are not automatically removed but annotated, allowing users to make context-specific decisions during subsequent analyses.

The QC flagging system supports:

* User-defined QC stage columns (e.g. range_test, persistence_test, step_test)
* Fully customizable flag values and classification schemes (e.g. VALID, SUSPECT, REVIEW, DELETE)
* Conflict detection
* Initial flag assignment and reclassification workflows
* Documentation of expert reviews and design decisions independent of flag assignments
* Merge-safe flag assignment workflows

### QC Documentation

Every QC decision can be documented through an audit-log framework that records:

* Timestamp
* Device
* Action
* Pipeline stage
* Previous flag state
* New flag state
* Reason for decision
* Number of affected observations
* Support for both flag-based and non-flag-based documentation

This supports reproducibility and transparent data governance by documenting expert reviews, preprocessing decisions and QC results.

## Planned Quality Control Tests

The following station-internal quality control procedures are currently under development:

### Completeness

* Missing value assessment
* Completeness tests

### Tolerance Tests

* Range tests

### Internal Consistency

* Physically plausible relationships between variables and derived statistics (e.g. Tmin < Tmean < Tmax, Wind Gust ≥ Wind Speed, Air Temperature ≥ Dew Point Temperature)

### Temporal Consistency

* Persistence tests
* Step tests

### Summarization

* Summary-based QC diagnostics

## Repository Structure

```text
RScripts/
├── hydro_pipeline/
├── meteo_pipeline/
├── master_script/
└── utils/
    └── QC_functions/

CITATION.cff
LICENSE
README.md
renv.lock
```

## Development Background

The quality control framework is informed by international guidance and literature on hydrometeorological quality control, environmental monitoring and reproducible scientific computing, including recommendations from WMO (2011), Estévez et al. (2011), Bushnell & Worthington (2016), Manola et al. (2020) and Wilson et al. (2017).

## Citation

If you use this software in academic work, please cite the repository using the information provided in `CITATION.cff`.

## License

Licensed under the Apache License 2.0.