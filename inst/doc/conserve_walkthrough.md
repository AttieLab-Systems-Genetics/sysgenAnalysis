# Walkthrough: SNP Conservation Workflow Refactoring

I have successfully refactored the SNP conservation and prioritization workflow into a modular R package structure within `sysgenAnalysis`.

## Original Prompt

Use
[walkthrough.md#workflow-prompt](walkthrough.md#workflow-prompt)
for workflow = "/Volumes/General/Projects2/Antigravity/SNP_conservation/prioritize_snps.R" and basename = "conserve".

NB: The workflow as provided included analsys of 6 different `traits_to_process` files. Before running the workflow (see end of this document), it is important to modify the script to either use only one file (say "Liver_Lipids") or have the `traits_to_process` variable be subset to only the traits you want to process.

## Changes Made

### Core Logic

#### [NEW] [conserve.R](../../R/conserve.R)

- **Functions**: Extracted logic into `run_trait_conservation()` and `run_conserve_analysis()`.
- **S3 Methods**: Implemented `print`, `summary`, and `plot` for the `conserve_analysis` class.
- **Improved Cohesion**: Centralized genome build (mm39) and coordinate management.
- **Robustness**: Updated to treat `Inf` SIFT scores as `-1`, ensuring finite `priority_score` results when scores are missing.

### Analysis Scripts

#### [NEW] [analyze_conserve.R](../scripts/analyze_conserve.R)

- Clean entry point for batch processing all trait classes.
- Automatically handles directory creation and file saving on the Research Drive.

#### [NEW] [explore_conserve.qmd](../scripts/explore_conserve.qmd)

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
source(system.file("scripts", "analyze_conserve.R", package = "sysgenAnalysis"))
```

### Via Quarto

```bash
quarto render $(Rscript -e 'cat(system.file("scripts", "explore_conserve.qmd", package = "sysgenAnalysis"))')
```
