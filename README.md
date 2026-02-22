# sysgenAnalysis

Systems Genetics Analysis

Routines for systems analysis with Attie Lab.

## Installation

You can install the development version of `sysgenAnalysis` from [GitHub](https://github.com/AttieLab-Systems-Genetics/sysgenAnalysis) with:

```r
# install.packages("devtools")
devtools::install_github("AttieLab-Systems-Genetics/sysgenAnalysis")
```

## Scripts

See the [QTL Analysis](inst/scripts/qtl_analysis.qmd) and [Hotspot Analysis](inst/scripts/hotspot_analysis.qmd) scripts for examples of how to use the package.
There are R code versions in inst/scripts/ as well.

If the package is installed, you can source the R scripts directly:

```r
source(system.file("scripts", "qtl_analysis.R", package = "sysgenAnalysis"))
source(system.file("scripts", "hotspot_analysis.R", package = "sysgenAnalysis"))
```

You can also render the Quarto reports to HTML:

```bash
quarto render $(Rscript -e 'cat(system.file("scripts", "qtl_analysis.qmd", package = "sysgenAnalysis"))')
quarto render $(Rscript -e 'cat(system.file("scripts", "hotspot_analysis.qmd", package = "sysgenAnalysis"))')
```

## Code Development

Check out the [Walkthrough](inst/doc/walkthrough.md) for a summary of recent work and package structure.
See
[Artificial Intelligence (AI) References](https://github.com/byandell/Documentation/blob/main/AI.md)
for helpful references.
