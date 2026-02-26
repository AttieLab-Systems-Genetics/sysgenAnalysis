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

1. **Execution**: Run the `_analysis.R` script locally or on the research drive to process data, identify peaks/hotspots, and save the results as CSV files.
2. **Exploration**: Render the `_explore.qmd` report to visualize the results. These reports load the saved CSVs (no re-running of analysis) and provide interactive summaries.

### Available Workflows

| Component | Execution Script | Exploration Report |
|-----------|------------------|--------------------|
| **QTL** | [qtl_analysis.R](inst/scripts/qtl_analysis.R) | [qtl_explore.qmd](inst/scripts/qtl_explore.qmd) |
| **Hotspots** | [hotspot_analysis.R](inst/scripts/hotspot_analysis.R) | [hotspot_explore.qmd](inst/scripts/hotspot_explore.qmd) |
| **SNP Conservation** | [conserve_analysis.R](inst/scripts/conserve_analysis.R) | [conserve_explore.qmd](inst/scripts/conserve_explore.qmd) |

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
sysgenAnalysis::render_explore("qtl", output_dir = ".")
sysgenAnalysis::render_explore("hotspot", output_dir = ".")
```

## Code Development

Check out the [Walkthrough](inst/doc/walkthrough.md) for a summary of recent work and package structure.
See
[Artificial Intelligence (AI) References](https://github.com/byandell/Documentation/blob/main/AI.md)
for helpful references.
