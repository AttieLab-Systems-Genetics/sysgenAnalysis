# SNP Conservation Analysis Script
# Refactored entry point for prioritize_snps.R

# 1. Setup
if (!requireNamespace("sysgenAnalysis", quietly = TRUE)) {
    devtools::install_github("AttieLab-Systems-Genetics/sysgenAnalysis")
}
library(sysgenAnalysis)
library(ggplot2)
library(data.table)

# 2. Configuration
# Resolve base data directory
base_research_dir <- research_dir()
top_snp_dir <- file.path(base_research_dir, "top_snps_high_moderate_impact/one_row_per_qtl_variant")

traits_to_process <- list(
    "Liver_Lipids" = file.path(top_snp_dir, "DO1200_liver_lipids_all_mice_additive_top_snps_high_mod_impact_collapsed.csv"),
    "Liver_Metabolites" = file.path(top_snp_dir, "DO1200_liver_metabolites_labeled_all_mice_additive_top_snps_high_mod_impact_collapsed.csv"),
    "Plasma_Metabolites" = file.path(top_snp_dir, "DO1200_plasma_metabolites_all_mice_diet_interactive_top_snps_high_mod_impact_collapsed.csv"),
    "Clinical_Traits" = file.path(top_snp_dir, "DO1200_clinical_traits_all_mice_additive_top_snps_high_mod_impact_collapsed.csv"),
    "Liver_Genes" = file.path(top_snp_dir, "DO1200_liver_genes_all_mice_additive_top_snps_high_mod_impact_collapsed.csv"),
    "Liver_Isoforms" = file.path(top_snp_dir, "DO1200_liver_isoforms_all_mice_additive_top_snps_high_mod_impact_collapsed.csv")
)

# Output directory (on Research Drive)
base_out <- file.path(dirname(base_research_dir), "Projects2/Antigravity/SNP_conservation")
ensure_dir(base_out)

# 3. Run Analysis
message("Starting SNP conservation analysis...")
results <- run_conserve_analysis(traits_to_process)

# 4. Persistence & Visualization
message("Saving results and plots...")

# Save trait-specific results and plots
for (t_name in names(results$all_results)) {
    trait_dir <- file.path(base_out, t_name)
    ensure_dir(trait_dir)

    # Save CSV
    fwrite(results$all_results[[t_name]], file.path(trait_dir, paste0("prioritized_", t_name, "_snps.csv")))

    # Save Manhattan Plot
    p_trait <- plot(results, trait_name = t_name)
    ggsave(file.path(trait_dir, paste0(t_name, "_manhattan.png")), p_trait, width = 14, height = 6, dpi = 300)
}

# Save global hotspot results and plots
hs_cols <- c(
    "variant_id", "gene_symbol", "trait_class_count", "trait_classes", "specific_traits",
    "max_priority", "variant_chr", "variant_pos_bp", "variant_pos_mbp", "rs_number",
    "qtl_chr", "qtl_pos",
    "consequence", "impact", "aa_pos", "aa_change", "avg_phastCons", "max_variant_lod"
)

fwrite(results$hotspots[, ..hs_cols], file.path(base_out, "global_hotspot_variants.csv"))

p_global <- plot(results)
if (!is.null(p_global)) {
    ggsave(file.path(base_out, "global_hotspot_manhattan.png"), p_global, width = 14, height = 6, dpi = 300)
}

message("All analyses complete! Results unified in: ", base_out)
