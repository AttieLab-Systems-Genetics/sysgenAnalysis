# Project Walkthroughs

The [Script Transformation Prompt](prompt.md) provides a concise summary of the standard refactoring process used in this project.

- [2026-02-11: QTL Analysis Pipeline Refactoring](#2026-02-11-qtl-analysis-pipeline-refactoring)
- [2026-02-16: R Package Conversion and Refactoring](#2026-02-16-r-package-conversion-and-refactoring)
- [2026-02-18: S3 Class Refactoring for QTL and Hotspot Analysis](#2026-02-18-s3-class-refactoring-for-qtl-and-hotspot-analysis)
- [2026-02-18: Interactive Quarto Reports](#2026-02-18-interactive-quarto-reports)

## 2026-02-11: QTL Analysis Pipeline Refactoring

Today's work focused on summarizing, extracting, and refactoring the core analysis infrastructure for the Diversity Outbred (DO) project.

### 1. Created Initial Pipeline Summary

I created a new file [initial_pipeline.md](initial_pipeline.md) which provides a concise overview of the five functional modules found in the main `README.md`.

### 2. Verified Context

I used the existing `Context review DO eQTL and correlation analysis.md`
in Box folder `R_stuff/Workflow summaries` as a guide to ensure consistency in terminology and scope.

### 3. Extracted QTL Analysis Functions

I extracted core functions from the `Standalone script for analyzing diet and sex specific liver metabolite QTL.R` in Research Drive folder `mkeller3/General/Projects2/R scripts` into [qtl.R](qtl.R).

- **Functions Extracted**: `get_specificity`, `summarize_qtl_specificity`, `generate_clean_manhattan`, and `identify_hotspots`.
- **Documentation**: All functions are documented using **Roxygen2** syntax.
- **Portability**: Included GRCm39 coordinate constants (`chr_lens`, `GLOBAL_MAP`) to ensure the functions work as a standalone utility.

### 4. Extracted Hotspot Analysis Functions

I also extracted functions for `Trans eQTL hotspot analysis for sex and diet split eQTL summary files.R` in Research Drive folder `mkeller3/General/Projects2/R scripts` into [hotspot.R](hotspot.R).

- **Functions Extracted**: `load_trans_eqtls`, `calculate_hotspot_density`, `plot_hotspots`, `find_differential_hotspots`, and `plot_differential_hotspots`.
- **Documentation**: Documented with **Roxygen2** syntax for clear parameter and return value identification.

### 5. Refactored QTL Analysis Script

I refactored the `Standalone script for analyzing diet and sex specific liver metabolite QTL.R` in Research Drive folder `mkeller3/General/Projects2/R scripts` into [qtl_analysis.R](qtl_analysis.R).

- **Streamlined**: Removed over 200 lines of redundant function definitions.
- **Library Integration**: Now sources shared logic from `qtl.R`.
- **Full Logic**: Retains all execution steps for data preparation, multi-class analysis, hotspot identification, and integrated plotting.

### 6. Refactored Hotspot Analysis Script

I also refactored the `Trans eQTL hotspot analysis for sex and diet split eQTL summary files.R` in Research Drive folder `mkeller3/General/Projects2/R scripts` into [hotspot_analysis.R](hotspot_analysis.R).

- **Consolidated**: Moved all loading, density, and plotting functions to `hotspot.R`.
- **Logic Intact**: The script remains fully functional for both Diet and Sex hotspot comparisons and differential trait extraction.

### 7. Centralized Shared Utilities

I created [common.R](common.R) to house shared infrastructure:

- **GRCm39 Coordinates**: Centralized chromosome lengths and global map configuration.
- **Shared Helpers**: Added `ensure_dir()` and `clean_chr_factor()` to standardize boilerplate across modules.
- **Color Palettes**: Standardized Diet, Sex, and Trait Class colors.

## Next Steps

- Run the analysis scripts:

  ```r
  source("inst/scripts/qtl_analysis.R")
  source("inst/scripts/hotspot_analysis.R")
  ```

- Or source the libraries (always source `common.R` first if loading individually):

  ```r
  source("R/common.R")
  source("R/qtl.R")
  source("R/hotspot.R")
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
- **Hotspot Analysis**: Created `run_hotspot_analysis()` to automate density calculation and differential analysis.
- **Streamlined Scripts**: Refactored `qtl_analysis.R` and `hotspot_analysis.R` into concise entry points that leverage these new functions.

### 4. Code Cleanup

- **Package Directory Rename**: Renamed the root directory from `sysgen_analysis` to `sysgenAnalysis` for consistency with the package name.
- **Git Remote Update**: Updated `origin` to `https://github.com/AttieLab-Systems-Genetics/sysgenAnalysis.git`.
- **Deleted `dir.R`**: Relocated configuration logic into the package core.
- **Documentation**: Generated full package documentation using `devtools::document()`.

## 2026-02-18: S3 Class Refactoring for QTL and Hotspot Analysis

Today's work refactored both the QTL and Hotspot analysis pipelines to use a more idiomatic R approach with S3 classes. This change separates the heavy lifting of the analysis from data persistence, providing more flexibility and better organization.

### 1. QTL Analysis S3 Refactor

- **S3 Class `qtl_analysis`**: Modified `run_qtl_analysis()` to return an object of class `qtl_analysis`.
- **Methods**: Implemented `print()`, `summary()`, and `plot()` methods for the `qtl_analysis` class.
- **Modularity**: Removed internal file saving logic from `run_qtl_analysis()`.

### 2. Hotspot Analysis S3 Refactor

- **S3 Class `hotspot_analysis`**: Modified `run_hotspot_analysis()` to return an object of class `hotspot_analysis`.
- **Plotting Functions**: Refactored `plot_hotspots()` and `plot_differential_hotspots()` to return `ggplot` objects instead of saving them internally.
- **Methods**: Implemented `print()`, `summary()`, and `plot()` methods for the `hotspot_analysis` class.

### 3. Updated Entry Point Scripts

- **`qtl_analysis.R`**: Updated to capture the `qtl_analysis` object and handle file saving locally.
- **`hotspot_analysis.R`**: Updated to capture the `hotspot_analysis` object and use the new methods to inspect, summarize, and plot results.

## 2026-02-18: Interactive Quarto Reports

I've converted the core analysis scripts into Quarto markdown (`.qmd`) documents. These files provide an interactive and visually rich way to explore the results, combining documentation, code, and live plots.

### 1. New Quarto Documents

- **`qtl_analysis.qmd`**: A full report for QTL specificity and integrated Manhattan plotting.
- **`hotspot_analysis.qmd`**: A report for trans-eQTL hotspot density and differential analysis.

### 2. How to Use

You can render these reports to HTML or PDF using the Quarto CLI or RStudio:

```bash
# From the terminal
quarto render inst/scripts/qtl_analysis.qmd
quarto render inst/scripts/hotspot_analysis.qmd
```

Within RStudio, simply open the `.qmd` file and click the **Render** button. These reports display plots inline and include a "Data Persistence" section that is disabled by default (to avoid accidental overwrites) but can be enabled to save the analysis artifacts.
