# GC/MS Pipeline for Matlab

Data processing pipeline for GC/MS data files. Import raw data files, detect chromtographic peaks, perform spectral matching of mass spectra across samples, and sync results to a SQL database.

___

#### Key Features

**Import Data**
 * Agilent (*.D) data files
 * NIST (*.MSP) mass spectra library files

**Data Preprocessing**
 * Baseline correction
 * Centroid mass spectra

**Peak Detection**
 * Find and integrate chromatographic peaks

**Spectra Matching**
 * Identify unknown peaks using a library of annotated spectra
 * Match unknown peaks to peaks in other samples

**Export Data**
 * SQLite database
 * CSV file

#### Requirements
* Matlab (>= R2019)

___

