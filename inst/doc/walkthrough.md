# Project Walkthroughs

- [2026-02-11: QTL Analysis Pipeline Refactoring](#2026-02-11-qtl-analysis-pipeline-refactoring)
- [2026-02-16: R Package Conversion and Refactoring](#2026-02-16-r-package-conversion-and-refactoring)

## 2026-02-11: QTL Analysis Pipeline Refactoring

Today's work focused on summarizing, extracting, and refactoring the core analysis infrastructure for the Diversity Outbred (DO) project.

### 1. Created Initial Pipeline Summary

I created a new file [initial_pipeline.md](initial_pipeline.md) which provides a concise overview of the five functional modules found in the main `README.md`.

### 2. Verified Context

I used the existing [Context review](../Workflow%20summaries/Context%20review%20DO%20eQTL%20and%20correlation%20analysis.md) as a guide to ensure consistency in terminology and scope.

### 3. Extracted QTL Analysis Functions

I extracted core functions from the [standalone QTL script](../Scripts/Unedited%20scripts/Standalone%20script%20for%20analyzing%20diet%20and%20sex%20specific%20liver%20metabolite%20QTL.R)
into [qtl.R](qtl.R).

- **Functions Extracted**: `get_specificity`, `summarize_qtl_specificity`, `generate_clean_manhattan`, and `identify_hotspots`.
- **Documentation**: All functions are documented using **Roxygen2** syntax.
- **Portability**: Included GRCm39 coordinate constants (`chr_lens`, `GLOBAL_MAP`) to ensure the functions work as a standalone utility.

### 4. Extracted Hotspot Analysis Functions

I also extracted functions for [trans-eQTL hotspot analysis](../Scripts/Unedited%20scripts/Trans%20eQTL%20hotspot%20analysis%20for%20sex%20and%20diet%20split%20eQTL%20summary%20files.R) into [hotspot.R](hotspot.R).

- **Functions Extracted**: `load_trans_eqtls`, `calculate_hotspot_density`, `plot_hotspots`, `find_differential_hotspots`, and `plot_differential_hotspots`.
- **Documentation**: Documented with **Roxygen2** syntax for clear parameter and return value identification.

### 5. Refactored QTL Analysis Script

I refactored the [standalone QTL analysis script](../Scripts/Unedited%20scripts/Standalone%20script%20for%20analyzing%20diet%20and%20sex%20specific%20liver%20metabolite%20QTL.R)
into [qtl_analysis.R](qtl_analysis.R).

- **Streamlined**: Removed over 200 lines of redundant function definitions.
- **Library Integration**: Now sources shared logic from `qtl.R`.
- **Full Logic**: Retains all execution steps for data preparation, multi-class analysis, hotspot identification, and integrated plotting.

### 6. Refactored Hotspot Analysis Script

I also refactored the [trans-eQTL hotspot analysis script](../Scripts/Unedited%20scripts/Trans%20eQTL%20hotspot%20analysis%20for%20sex%20and%20diet%20split%20eQTL%20summary%20files.R) into [hotspot_analysis.R](hotspot_analysis.R).

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
  source("byandell/qtl_analysis.R")
  source("byandell/hotspot_analysis.R")
  ```

- Or source the libraries (always source `common.R` first if loading individually):

  ```r
  source("byandell/common.R")
  source("byandell/qtl.R")
  source("byandell/hotspot.R")

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
