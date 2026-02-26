# script_summary.md: Summary of Specialized R Scripts

This document provides a summary of the specialized R scripts found in `Scripts/Edited scripts/`. These scripts extend the core QTL analysis workflow to address specific biological questions and automate common tasks in the local Mac environment.

## 1. Local Environment & Automation

- **[Mac_QTL_Analysis_Function.R](../Scripts/Edited%20scripts/Mac_QTL_Analysis_Function.R)**: Master function to encapsulate the QTL analysis workflow, adapted for local Mac paths and network drive access.
- **[Corrected_Mac_QTL_Script.R](../Scripts/Edited%20scripts/Corrected_Mac_QTL_Script.R)**: A large consolidated script containing analyzed clusters and mapping data, likely representing a saved state of the primary Mac-adapted analysis.

## 2. Multi-Omic Correlations

- **[Glutarylcarnitine-RNA_isoform correlations.R](../Scripts/Edited%20scripts/Glutarylcarnitine-RNA_isoform%20correlations.R)**: An interactive script designed to correlate specific metabolites (e.g., `liver_GLUTARYLCARNITINE_m1_pos`) with gene isoforms (e.g., `Slc7a7`). It calculates Pearson correlations, p-values, and generates a PDF report with scatter plots.
- **[RNA correlations for Pdp2.R](../Scripts/Edited%20scripts/RNA%20correlations%20for%20Pdp2.R)**: Focuses on the `Pdp2` gene. It maps transcript IDs, correlates `Pdp2` expression against all RNA features, calculates FDR-corrected p-values, and exports top positive and negative correlations.
- **[correlation of metabolite with RNA.R](../Scripts/Edited%20scripts/correlation%20of%20metabolite%20with%20RNA.R)**: A general-purpose tool to calculate correlations between metabolite levels and transcript expression.

## 3. Mitochondrial Gene Analysis

- **[mito_gene_additive_isoform_eqtl.R](../Scripts/Edited%20scripts/mito_gene_additive_isoform_eqtl.R)**: Workflows for eQTL mapping of target mitochondrial genes (e.g., *Mcat*, *Oxsm*, *Mecr*). Generates Manhattan plots highlighting cis and trans effect peaks.
- **[mito_gene_diet_interactive_isoform_eqtl.R](../Scripts/Edited%20scripts/mito_gene_diet_interactive_isoform_eqtl.R)**: Similar to the additive script but focuses on identifying eQTLs that interact with diet (HC vs HF).
- **[mito_gene_heat plot.R](../Scripts/Edited%20scripts/mito_gene_heat%20plot.R)**: Visualization tool to create heatmaps for mitochondrial gene expression or QTL results.
- **[mito_lipid_genes_heat_plot_vs_strain_effects.R](../Scripts/Edited%20scripts/mito_lipid_genes_heat_plot_vs_strain_effects.R)**: Visualizes the effects of different founder strains (A-H) on lipid-related mitochondrial genes.

## 4. Hotspot & Regional Analysis

- **[Chr15_Hotspot_Analysis_Logic.R](../Scripts/Edited%20scripts/Chr15_Hotspot_Analysis_Logic.R)**: Specific investigation into lipid phenotypes clustering on Chromosome 15. It filters for relevant traits and prepares them for strain effect visualization.

## 5. Data Processing Utilities

- **[Link transcripts to gene names.R](../Scripts/Edited%20scripts/Link%20transcripts%20to%20gene%20names.R)**: A utility script to map Ensembl transcript IDs to human-readable gene symbols, facilitating biological interpretation of QTL results.
- **[Analysis_Pipeline_QTL_Multiple traits.R](../Scripts/Edited%20scripts/Analysis_Pipeline_QTL_Multiple%20traits.R)**: (Placeholder/Template) A shell for analyzing multiple trait classes simultaneously.

## Relationship to `byandell/` Analysis Scripts

The scripts summarized above in `Scripts/Edited scripts/` represent specialized biological investigations and the evolutionary development of the project. They relate to the primary analysis scripts in the `byandell/` directory as follows:

1. **Refinement vs. Exploration**: The scripts in `byandell/` ([analyze_qtl.R](analyze_qtl.R), [analyze_hotspot.R](analyze_hotspot.R)) are the refined, project-wide workflows. They utilize the standardized environment defined in [dir.R](dir.R) and [common.R](common.R). In contrast, the scripts in `Edited scripts/` are exploratory "deep dives" into specific genes (e.g., *Pdp2*, *Slc7a7*) or regions (e.g., Chromosome 15).
2. **Modularity**: The core logic from `Edited scripts/` has been modularized into shared libraries. These functions are now used to drive the production workflows:
    - **[qtl.R](qtl.R)**: Formalizes logic from `Mac_QTL_Analysis_Function.R` and `Analysis_Pipeline_QTL_Multiple traits.R`.
        - `get_specificity()`: Standardizes the "Shared" vs "Specific" comparison logic.
        - `generate_clean_manhattan()`: Provides the GRCm39-sanitized plotting logic.
        - `identify_hotspots()`: Encapsulates the phenotypic clustering logic used in regional analysis.
    - **[hotspot.R](hotspot.R)**: formalizes logic from `Chr15_Hotspot_Analysis_Logic.R` and specialized eQTL summaries.
        - `calculate_hotspot_density()`: Implements sliding-window analysis for trans-eQTLs.
        - `find_differential_hotspots()`: Automates the identification of divergent peaks between experimental groups (Sex/Diet).
3. **Specialization**: While `byandell/qtl_analysis.R` provides a framework for large-scale batch processing using `summarize_qtl_specificity()`, scripts in `Edited scripts/` provide templates for interactive analysis and specialized reporting (e.g., Pearson correlation PDFs).
4. **Targeted Analysis**: `byandell/hotspot_analysis.R` identifies global hotspots across all trait classes, whereas scripts like `Chr15_Hotspot_Analysis_Logic.R` provide the specific logic required to probe a single major cluster in detail.

In summary, the `byandell/` scripts provide the **production-ready foundation**, while the `Edited scripts/` provide the **specialized logic and exploratory history** for targeted biological discovery.
