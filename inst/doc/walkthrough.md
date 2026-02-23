# Pipeline Walkthrough

## Script Transformation Prompt

**Goal**: Refactor a pipeline into a modular R package structure.

**Instructions**:

1. **Extract Functions**: Move all logical units (data processing, analysis, plotting) into `R/[basename].R`.
    - Document each function with **Roxygen2** syntax (including `@param`, `@return`, and `@export`).
    - Use R native pipes (`|>`) and explicit namespace calls (e.g., `dplyr::mutate`).
    - Centralize shared constants (like coordinate maps) if not already in `common.R`.

2. **Create Entry Script**: Create an execution script `inst/scripts/[basename]_analysis.R`.
    - Use it as a clean entry point that calls the functions defined in `R/`.
    - Handle environment setup, file paths, and high-level execution flow here.

3. **Return S3 Objects**: Refactor the main "run" function to return an S3 object of class `[basename]_analysis`.
    - Implement `print`, `summary`, and `plot` methods in `R/[basename].R`.
    - Move file-saving logic (`write.csv`, `ggsave`) out of the functions and into the entry script.

**Requested Files**:

- `R/[basename].R`
- `inst/scripts/[basename]_analysis.R`
- `inst/scripts/[basename]_analysis.qmd` (Quarto version)

## Preamble

The analysis scripts used in this project are located on the Research Drive at `mkeller3/General/Projects2/R scripts`. This project focuses on two primary pipelines, referred to as `[basename]_pipeline`:

- `qtl_pipeline` (based on `Standalone script for analyzing diet and sex specific liver metabolite QTL.R`)
- `hotspot_pipeline` (based on `Trans eQTL hotspot analysis for sex and diet split eQTL summary files.R`)

Subsequent sections in this walkthrough will detail the refactoring steps using the `qtl` basename (or generic `[basename]`) as the primary example.

## Project Walkthroughs

- [2026-02-11: QTL Analysis Pipeline Refactoring](#2026-02-11-qtl-analysis-pipeline-refactoring)
- [2026-02-16: R Package Conversion and Refactoring](#2026-02-16-r-package-conversion-and-refactoring)
- [2026-02-18: S3 Class Refactoring for QTL and Hotspot Analysis](#2026-02-18-s3-class-refactoring-for-qtl-and-hotspot-analysis)
- [2026-02-18: Interactive Quarto Reports](#2026-02-18-interactive-quarto-reports)
- [2026-02-18: Bug Fixes and Automation Improvements](#2026-02-18-bug-fixes-and-automation-improvements)

## 2026-02-11: QTL Analysis Pipeline Refactoring

Today's work focused on summarizing, extracting, and refactoring the core analysis infrastructure for the Diversity Outbred (DO) project.

### 1. Created Initial Pipeline Summary

I created a new file [initial_pipeline.md](initial_pipeline.md) which provides a concise overview of the five functional modules found in the main `README.md`.

### 2. Verified Context

I used the existing `Context review DO eQTL and correlation analysis.md`
in Box folder `R_stuff/Workflow summaries` as a guide to ensure consistency in terminology and scope.

### 3. Extracted Pipeline Functions

I extracted core functions from the Research Drive folder into `R/[basename].R` (e.g., [qtl.R](qtl.R)).

- **Functions Extracted**: `get_specificity`, `summarize_qtl_specificity`, `generate_clean_manhattan`, and `identify_hotspots`.
- **Documentation**: All functions are documented using **Roxygen2** syntax.
- **Portability**: Included GRCm39 coordinate constants (`chr_lens`, `GLOBAL_MAP`) to ensure the functions work as a standalone utility.

### 4. Refactored Analysis Script

I refactored the original scripts from the Research Drive folder into `inst/scripts/[basename]_analysis.R` (e.g., [qtl_analysis.R](qtl_analysis.R)).

- **Streamlined**: Removed over 200 lines of redundant function definitions.
- **Library Integration**: Now sources shared logic from `R/`.
- **Full Logic**: Retains all execution steps for data preparation, multi-class analysis, hotspot identification, and integrated plotting.

### 5. Centralized Shared Utilities

I created [common.R](common.R) to house shared infrastructure:

- **GRCm39 Coordinates**: Centralized chromosome lengths and global map configuration.
- **Shared Helpers**: Added `ensure_dir()` and `clean_chr_factor()` to standardize boilerplate across modules.
- **Color Palettes**: Standardized Diet, Sex, and Trait Class colors.

## Next Steps

- Run the analysis scripts:

  ```r
  source("inst/scripts/qtl_analysis.R")
  ```

- Or source the libraries (always source `common.R` first if loading individually):

  ```r
  source("R/common.R")
  source("R/qtl.R")
  ```

## 2026-02-16: R Package Conversion and Refactoring

Today's work focused on fully converting the `sysgenAnalysis` directory into a functional, best-practice R package named `sysgenAnalysis`.

### 1. Package Infrastructure

- **Infrastructure Files**: Added `DESCRIPTION`, `NAMESPACE`, and `.Rbuildignore`.
- **Dependency Management**: Centralized all dependencies in the `DESCRIPTION` file, removing the need for manual `library()` calls in scripts.

### 2. Modernization and Refactoring

- **Pipe Migration**: Replaced all `magrittr` pipes (`%>%`) with R native pipes (`|>`) for better performance and fewer dependencies.
- **Explicit Imports**: Updated all functions to use specific `@importFrom` tags, improving namespace clarity and avoiding conflicts.
- **Directory Management**: Implemented a cross-platform `research_dir()` function in `common.R` to handle Mac (`/Volumes`) and PC (`W:`) paths automatically.

### 3. Analysis Pipeline Encapsulation

- **QTL Analysis**: Created `run_qtl_analysis()` to encapsulate the entire specificity and hotspot logic.
- **Streamlined Scripts**: Refactored `qtl_analysis.R` into a concise entry point that leverages these new functions.

### 4. Code Cleanup

- **Package Directory Rename**: Renamed the root directory from `sysgen_analysis` to `sysgenAnalysis` for consistency with the package name.
- **Git Remote Update**: Updated `origin` to `https://github.com/AttieLab-Systems-Genetics/sysgenAnalysis.git`.
- **Deleted `dir.R`**: Relocated configuration logic into the package core.
- **Documentation**: Generated full package documentation using `devtools::document()`.

## 2026-02-18: S3 Class Refactoring for QTL and Hotspot Analysis

Today's work refactored both the QTL and Hotspot analysis pipelines to use a more idiomatic R approach with S3 classes. This change separates the heavy lifting of the analysis from data persistence, providing more flexibility and better organization.

### 1. S3 Class Refactor

- **S3 Class `qtl_analysis`**: Modified `run_qtl_analysis()` to return an object of class `qtl_analysis`.
- **Methods**: Implemented `print()`, `summary()`, and `plot()` methods for the `qtl_analysis` class.
- **Modularity**: Removed internal file saving logic from `run_qtl_analysis()`.
- **`qtl_analysis.R`**: Updated to capture the `qtl_analysis` object and handle file saving locally.

## 2026-02-18: Interactive Quarto Reports

I've converted the core analysis scripts into Quarto markdown (`.qmd`) documents. These files provide an interactive and visually rich way to explore the results, combining documentation, code, and live plots.

### 1. New Quarto Documents

- **`qtl_analysis.qmd`**: A full report for QTL specificity and integrated Manhattan plotting.

### 2. How to Use

You can render these reports to HTML or PDF using the Quarto CLI or RStudio:

```bash
# From the terminal
quarto render inst/scripts/qtl_analysis.qmd
```

Within RStudio, simply open the `.qmd` file and click the **Render** button. These reports display plots inline and include a "Data Persistence" section that is disabled by default (to avoid accidental overwrites) but can be enabled to save the analysis artifacts.

## 2026-02-18: Bug Fixes and Automation Improvements

The final phase of today's work addressed unexpected bugs discovered during verification and improved the package's portability.

### 1. Identify Hotspots Argument Fix

Resolved an error where `identify_hotspots` could not find the `group` column. I standardized the grouping column name to lowercase `group` across the entire package (`R/qtl.R` and `R/hotspot.R`) to ensure seamless integration between logic and plotting.

### 2. Load Trans eQTLs Vector Fix

Fixed a vector length recycling error in `load_trans_eqtls` that caused the hotspot analysis to fail when automatically converting base-pair positions to megabases. The fix ensures that position scaling is applied correctly to the entire dataset.

### 3. Conditional Package Installation

Added logic to all analysis scripts and Quarto documents in `inst/scripts/` to check for `sysgenAnalysis` and automatically install it from GitHub if it's not present. This makes the scripts truly standalone for collaborators.

```r
if (!requireNamespace("sysgenAnalysis", quietly = TRUE)) {
  devtools::install_github("AttieLab-Systems-Genetics/sysgenAnalysis")
}
library(sysgenAnalysis)
```

### 4. README and Workflow Finalization

- **README**: Updated with robust instructions for sourcing scripts from an installed package using `system.file()`.
- **Walkthrough**: Updated workflow references to use descriptive location text for Research Drive and Box files.

### 5. Verified Analysis Pipeline

Successfully ran and verified the outputs for `qtl_analysis.R` following the fixes.
