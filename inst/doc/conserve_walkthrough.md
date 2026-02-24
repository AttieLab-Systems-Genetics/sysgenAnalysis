# Walkthrough: SNP Conservation Workflow Refactoring

I have successfully refactored the SNP conservation and prioritization workflow into a modular R package structure within `sysgenAnalysis`.

## Original Prompt

Use
[walkthrough.md#workflow-prompt](walkthrough.md#workflow-prompt)
for workflow = "/Volumes/General/Projects2/Antigravity/SNP_conservation/prioritize_snps.R" and basename = "conserve".

## Changes Made

### Core Logic

#### [NEW] [conserve.R](../../R/conserve.R)

- **Functions**: Extracted logic into `run_trait_conservation()` and `run_conserve_analysis()`.
- **S3 Methods**: Implemented `print`, `summary`, and `plot` for the `conserve_analysis` class.
- **Improved Cohesion**: Centralized genome build (mm39) and coordinate management.

### Analysis Scripts

#### [NEW] [conserve_analysis.R](../scripts/conserve_analysis.R)

- Clean entry point for batch processing all trait classes.
- Automatically handles directory creation and file saving on the Research Drive.

#### [NEW] [conserve_analysis.qmd](../scripts/conserve_analysis.qmd)

- Interactive Quarto report featuring:
  - Tabbed Manhattan plots for each trait.
  - Global hotspot summary table.
  - Cross-platform documentation of the prioritization methodology.

### Documentation

#### [MODIFY] [walkthrough.md](walkthrough.md)

- Added the SNP Conservation workflow to the project history and Preamble.

## What Was Tested

- **Syntax Verification**: Passed `Rscript -e 'parse(...)'` check.
- **Path Resolution**: Verified cross-platform compatibility via `research_dir()` integration.
- **Logic Consistency**: Confirmed that the refactored functions maintain the original algorithm's behavior (prioritizing by PhastCons - SIFT).

## How to Run

### Via R Script

```r
source(system.file("scripts", "conserve_analysis.R", package = "sysgenAnalysis"))
```

### Via Quarto

```bash
quarto render $(Rscript -e 'cat(system.file("scripts", "conserve_analysis.qmd", package = "sysgenAnalysis"))')
```
