# sysgenAnalysis

Systems Genetics Analysis

Routines for systems analysis with Attie Lab.

## Installation

You can install the development version of `sysgenAnalysis` from [GitHub](https://github.com/AttieLab-Systems-Genetics/sysgenAnalysis) with:

```r
# install.packages("devtools")
devtools::install_github("AttieLab-Systems-Genetics/sysgenAnalysis")
```

## Workflows & Scripts

This package follows a two-step workflow for each analysis:

1. **Execution**: Run the `analyze_[basename].R` script locally or on the research drive to process data, identify peaks/hotspots, and save the results as CSV files.
2. **Exploration**: Render the `explore_[basename].qmd` report to visualize the results. These reports load the saved CSVs (no re-running of analysis) and provide interactive summaries.

### Available Workflows

| Component | Execution Script | Exploration Report |
|-----------|------------------|--------------------|
| **QTL** | [analyze_qtl.R](inst/scripts/analyze_qtl.R) | [explore_qtl.qmd](inst/scripts/explore_qtl.qmd) |
| **Hotspots** | [analyze_hotspot.R](inst/scripts/analyze_hotspot.R) | [explore_hotspot.qmd](inst/scripts/explore_hotspot.qmd) |
| **SNP Conservation** | [analyze_conserve.R](inst/scripts/analyze_conserve.R) | [explore_conserve.qmd](inst/scripts/explore_conserve.qmd) |

### Usage

If the package is installed, you can execute analysis workflows directly from the R console:

```r
library(sysgenAnalysis)

# Run the full analysis (saves CSVs for exploration)
sysgenAnalysis::run_analysis("qtl")
sysgenAnalysis::run_analysis("hotspot")
```

To render exploration reports, use the package helper:

```r
# This will save the HTML in your current folder
sysgenAnalysis::render_explore("qtl")
sysgenAnalysis::render_explore("hotspot")
```

## Code Development

Check out the [Walkthrough](inst/doc/walkthrough.md) for a summary of recent work and package structure.
See
[Artificial Intelligence (AI) References](https://github.com/byandell/Documentation/blob/main/AI.md)
for helpful references.
