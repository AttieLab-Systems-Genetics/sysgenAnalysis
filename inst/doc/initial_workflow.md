# Initial Workflow Summary

This document summarizes the core analytical infrastructure defined
in Alan Attie's `R_stuff` box folder `Scripts/README.md`, following the patterns established in the Diversity Outbred (DO) workflow. Most of `README.md` is from the
`Standalone script for analyzing diet and sex specific liver metabolite QTL.R`
located on the Research Drive at
`mkeller3/General/Projects2/R scripts`.
The standalone script is the better reference for the core workflow logic, but `Scripts/README.md` contains the specific Mac-friendly paths and the extra Glutarylcarnitine analysis Alan was working on previously.

## Core Analysis Modules

### 1. Data Preparation & Specificity Logic

- **Path Management**: Automated setup for Mac/Windows compatibility (network drives like `/Volumes/mkeller3`).
- **QTL Loading**: Imports additive peaks for **DO1200** cohorts (HC/HF Diets, Female/Male Sexes).
- **Specificity Analysis**: Computes "Shared" vs "Specific" QTL status using a **5Mb window** comparison between groups.

### 2. Sanitized Manhattan Visualization (GRCm39)

- **Sanitized Mapping**: Uses GRCm39 chromosome lengths and offsets for accurate genomic plotting.
- **Differential Plotting**: Visualizes LOD scores with distinct styling for Specific (solid) vs Shared (open) peaks.
- **High-LOD Handling**: Automatically crops and notes peaks with LOD > 100 for better scale visibility.

### 3. Multi-Class Trait Processing

- **Iterative Mapping**: Extends specificity logic across four major trait classes:
  - **Liver Metabolites** (Labeled)
  - **Plasma Metabolites**
  - **Liver Lipids**
  - **Clinical Traits**
- **Automated Export**: Generates categorized Manhattan plots for every trait x group combination.

### 4. Global Hotspot Analysis

- **Cluster Identification**: Groups traits into genomic clusters based on proximity (default 4Mb gap limit).
- **Hotspot Ranking**: Identifies regions with high phenotypic diversity (e.g., regions where multiple trait classes overlap).
- **Diversity Scoring**: Ranks hotspots by the variety of trait classes represented.

### 5. Automation & Verification

- **Output Validation**: Comprehensive logging to verify all tables and plots are successfully generated in the Box-Box output folders.
- **Workflow Automation**: Foundation for reusable functions (e.g., `Mac_QTL_Analysis_Function.R`) to streamline recurring analyses.
