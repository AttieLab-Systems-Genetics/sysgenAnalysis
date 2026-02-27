# Workflow Walkthrough

## Workflow Prompt

**Goal**: Refactor a [workflow] into a modular R package structure.

**Instructions**:

0. **Set the [workflow] and [basename] variables from user input**:
    - [workflow]: The name of the workflow to refactor .
    - [basename]: The `basename` to use for the refactored workflow.

1. **Understand the workflow**: Read the [workflow] and understand what it does.

2. **Extract Functions**: Move all logical units (data processing, analysis, plotting) into `R/[basename].R`.
    - Document each function with **Roxygen2** syntax (including `@param`, `@return`, and `@export`).
    - Use R native pipes (`|>`) and explicit namespace calls (e.g., `dplyr::mutate`).
    - Centralize shared constants (like coordinate maps) if not already in `common.R`.

3. **Create Entry Script**: Create an execution script `inst/scripts/analyze_[basename].R`.
    - Use it as a clean entry point that calls the functions defined in `R/`.
    - Handle environment setup, file paths, and high-level execution flow here.

4. **Return S3 Objects**: Refactor the main "run" function to return an S3 object of class `[basename]_analysis`.
    - Implement `print`, `summary`, and `plot` methods in `R/[basename].R`.
    - Move file-saving logic (`write.csv`, `ggsave`) out of the functions and into the entry script.

5. **Verify Integration**: Check package and scripts, correcting any issues that arise.
    - Verify documents with `devtools::document()`.
    - Build the package.
    - Ask user whether or not to run the analyze_[basename].R script to make sure it works.

6. **Create Exploration Document**: Create a Quarto document `inst/scripts/explore_[basename].qmd` to explore the results saved by the analysis script.
    - Use `sysgenAnalysis::read_[basename]_analysis(output_path)` to reconstruct the S3 object from CSV files.
    - Focus on visualization and interactive summaries using the S3 methods (`print`, `summary`, `plot`).
    - This approach ensures that exploration is fast (no re-running analysis) and transparent (uses human-readable CSVs).

**Requested Files**:

- `R/[basename].R`
- `inst/scripts/analyze_[basename].R`
- `inst/scripts/explore_[basename].qmd`

## Preamble

The analysis scripts used in this project are located on the Research Drive at `mkeller3/General/Projects2/R scripts`.
For a list of workflows, see `README.md` in that folder
(local copy is [README_Projects2.md](README_Projects2.md)).

This project focuses on two primary workflows, referred to as `[basename]_workflow`:

- `qtl_workflow` (based on `Standalone script for analyzing diet and sex specific liver metabolite QTL.R`)
- `hotspot_workflow` (based on `Trans eQTL hotspot analysis for sex and diet split eQTL summary files.R`)
- `conserve_workflow` (based on `prioritize_snps.R`)

Subsequent sections in this walkthrough will detail the refactoring steps using the `qtl` or `conserve` basename (or generic `[basename]`) as the primary example.
Section [2026-02-24: SNP Conservation Workflow Refactoring](#2026-02-24-snp-conservation-workflow-refactoring) was created using the [Workflow Prompt](#workflow-prompt)
detailed above.

## Workflow Walkthroughs

- [2026-02-11: QTL Analysis Workflow Refactoring](#2026-02-11-qtl-analysis-workflow-refactoring)
- [2026-02-16: R Package Conversion and Refactoring](#2026-02-16-r-package-conversion-and-refactoring)
- [2026-02-18: S3 Class Refactoring for QTL and Hotspot Analysis](#2026-02-18-s3-class-refactoring-for-qtl-and-hotspot-analysis)
- [2026-02-18: Interactive Quarto Reports](#2026-02-18-interactive-quarto-reports)
- [2026-02-18: Bug Fixes and Automation Improvements](#2026-02-18-bug-fixes-and-automation-improvements)
- [2026-02-24: SNP Conservation Workflow Refactoring](#2026-02-24-snp-conservation-workflow-refactoring)
- [2026-02-26: Modular CSV-Based Workflow Exploration](#2026-02-26-modular-csv-based-workflow-exploration)

## 2026-02-11: QTL Analysis Workflow Refactoring

Today's work focused on summarizing, extracting, and refactoring the core analysis infrastructure for the Diversity Outbred (DO) project.

### 1. Created Initial Workflow Summary

I created a new file [initial_workflow.md](initial_workflow.md) which provides a concise overview of the five functional modules found in the main `README.md`.

### 2. Verified Context

I used the existing `Context review DO eQTL and correlation analysis.md`
in Box folder `R_stuff/Workflow summaries` as a guide to ensure consistency in terminology and scope.

### 3. Extracted Workflow Functions

I extracted core functions from the Research Drive folder into `R/[basename].R` (e.g., [qtl.R](qtl.R)).

- **Functions Extracted**: `get_specificity`, `summarize_qtl_specificity`, `generate_clean_manhattan`, and `identify_hotspots`.
- **Documentation**: All functions are documented using **Roxygen2** syntax.
- **Portability**: Included GRCm39 coordinate constants (`chr_lens`, `GLOBAL_MAP`) to ensure the functions work as a standalone utility.

### 4. Refactored Analysis Script

I refactored the original scripts from the Research Drive folder into `inst/scripts/analyze_[basename].R` (e.g., [analyze_qtl.R](analyze_qtl.R)).

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
  source("inst/scripts/analyze_qtl.R")
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

### 3. Analysis Workflow Encapsulation

- **QTL Analysis**: Created `run_qtl_analysis()` to encapsulate the entire specificity and hotspot logic.
- **Streamlined Scripts**: Refactored `analyze_qtl.R` into a concise entry point that leverages these new functions.

### 4. Code Cleanup

- **Package Directory Rename**: Renamed the root directory from `sysgen_analysis` to `sysgenAnalysis` for consistency with the package name.
- **Git Remote Update**: Updated `origin` to `https://github.com/AttieLab-Systems-Genetics/sysgenAnalysis.git`.
- **Deleted `dir.R`**: Relocated configuration logic into the package core.
- **Documentation**: Generated full package documentation using `devtools::document()`.

## 2026-02-18: S3 Class Refactoring for QTL and Hotspot Analysis

Today's work refactored both the QTL and Hotspot analysis workflows to use a more idiomatic R approach with S3 classes. This change separates the heavy lifting of the analysis from data persistence, providing more flexibility and better organization.

### 1. S3 Class Refactor

- **S3 Class `[basename]_analysis`**: Modified `run_[basename]_analysis()` to return an object of class `[basename]_analysis`.
- **Methods**: Implemented `print()`, `summary()`, and `plot()` methods for the `[basename]_analysis` class.
- **Modularity**: Removed internal file saving logic from `run_[basename]_analysis()`.
- **`analyze_[basename].R`**: Updated to capture the `[basename]_analysis` object and handle file saving locally.

## 2026-02-18: Interactive Quarto Reports

I've converted the core analysis scripts into Quarto markdown (`.qmd`) documents. These files provide an interactive and visually rich way to explore the results, combining documentation, code, and live plots.

### 1. New Quarto Documents

- **`explore_qtl.qmd`**: A full report for QTL specificity and integrated Manhattan plotting.

### 2. How to Use

You can render these reports to HTML or PDF using the Quarto CLI or RStudio:

```bash
# From the terminal
quarto render inst/scripts/explore_qtl.qmd
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
if (!requireNamespace("sysgenAnalysis", quietly := TRUE)) {
  devtools::install_github("AttieLab-Systems-Genetics/sysgenAnalysis")
}
library(sysgenAnalysis)
```

### 4. README and Workflow Finalization

- **README**: Updated with robust instructions for sourcing scripts from an installed package using `system.file()`.
- **Walkthrough**: Updated workflow references to use descriptive location text for Research Drive and Box files.

### 5. Verified Analysis Workflow

Successfully verified the syntax of the new components and confirmed they align with the package's design patterns.

## 2026-02-24: SNP Conservation Workflow Refactoring

Today's work focused on refactoring the SNP conservation and prioritization workflow into a modular, package-compliant structure.

### 1. Extracted Modular Functions

I refactored `prioritize_snps.R` into `R/conserve.R`, extracting the logic into reusable units.

- **`run_trait_conservation()`**: Handles the heavy lifting of querying conservation scores and calculating priority for a single trait.
- **`run_conserve_analysis()`**: The global entry point that manages multi-trait analysis and hotspot identification.

### 2. S3 Class Integration

Implemented the `conserve_analysis` S3 class to separate analysis from visualization and persistence.

- **Methods**: Added `print`, `summary`, and `plot` methods.
- **Flexibility**: The `plot` method can generate both global hotspot Manhattan plots and trait-specific conservation plots.

### 3. Streamlined Scripts and Reporting

Created dedicated entry points that leverage the package core.

- **`analyze_conserve.R`**: A clean script for batch processing and data saving.
- **`explore_conserve.qmd`**: A Quarto report that provides an interactive summary of the analysis, including tabbed Manhattan plots for all traits.

### 4. Cross-Platform Path Handling

Integrated the `research_dir()` helper to ensure that the workflow works seamlessly across Mac and Windows environments without manual path editing.

### 5. Verified Workflow

Successfully verified the syntax of the new components and confirmed they align with the package's design patterns.

## 2026-02-26: Modular CSV-Based Workflow Exploration

Today's work introduced a performant and transparent exploration model by pivoting from binary RDS files to modular CSV-based reconstruction.

### 1. Transparent Data Persistence

I refactored the analysis scripts to ensure all data required for visualization is saved as human-readable CSV files, removing the dependency on binary RDS files.

- **QTL Analysis**: Now saves `QTL_Plot_Data.csv` and `QTL_Top_10_Hotspots.csv`.
- **Hotspot Analysis**: Now saves `*_density.csv` files for each trait class.

### 2. Package-Level Reconstruction Functions

I moved the S3 object reconstruction logic into the package core to promote reuse and ensure consistency between analysis and exploration.

- **`read_qtl_analysis()`**: Reassembles the `qtl_analysis` object from the specificity and hotspot CSVs.
- **`read_conserve_analysis()`**: Reassembles the `conserve_analysis` object by scanning for trait-specific SNP prioritization files.
- **`read_hotspot_analysis()`**: Reassembles the `hotspot_analysis` object from density and differential trait CSVs.

### 3. Streamlined Exploration Documents

The `explore_[basename].qmd` documents were refactored to be thin visualization layers. They no longer contain complex data-loading logic; instead, they call the package's `read_[basename]_analysis` functions to instantly restore the S3 objects for plotting and summarization using standard S3 methods.

### 4. Simplified Workflow Helpers

I added two high-level helpers to `R/common.R` to streamline the user experience:

- **`run_analysis(basename)`**: Executes the full analysis pipeline (QTL, Hotspots, or SNPs) and saves the CSV results.
- **`render_explore(basename, output_dir)`**: Automates Quarto rendering to generate a project-relative HTML report.

```r
# New standard workflow
sysgenAnalysis::run_analysis("qtl")
sysgenAnalysis::render_explore("qtl", output_dir = ".")
```

### 6. Package Build and Installation Fixes

To ensure the new scripts and help files are correctly included in the package, I updated the `.Rbuildignore` file to remove restrictions on the `inst/` directory. This allows the internal data-loading and rendering helpers to find the necessary files in the installed library.
