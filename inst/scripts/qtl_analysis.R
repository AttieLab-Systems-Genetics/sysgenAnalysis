# ===============================================================
# QTL Analysis Workflow: Specificity & Hotspots
# ===============================================================

# 1. Setup Environment
if (!requireNamespace("sysgenAnalysis", quietly = TRUE)) {
  devtools::install_github("AttieLab-Systems-Genetics/sysgenAnalysis")
}
library(sysgenAnalysis)

# 2. Configuration
data_dir <- research_dir()
save_dir <- "byandell/output"

input_path <- file.path(data_dir, "annotated_peak_summaries")
output_path <- file.path(save_dir, "QTL_Differential_Analysis")

trait_classes <- c(
  "liver_metabolites_labeled",
  "plasma_metabolites",
  "liver_lipids",
  "clinical_traits"
)

# 3. Execution
qtl_res <- run_qtl_analysis(
  phenotype_classes = trait_classes,
  qtl_model = "additive",
  input_dir = input_path,
  groups = c("HC", "HF", "female", "male"),
  rank_by = "Diversity"
)

# 4. Results & Persistence
print(qtl_res)

# Save Specificity Summary
summary_table <- summary(qtl_res)
if (!is.null(summary_table)) {
  ensure_dir(output_path)
  write.csv(summary_table,
    file.path(output_path, "QTL_Specificity_Summary_Table.csv"),
    row.names = FALSE
  )
}

# Save Hotspots
if (!is.null(qtl_res$final_hs)) {
  hotspot_dir <- file.path(output_path, "Hotspot_Analysis")
  ensure_dir(hotspot_dir)
  write.csv(qtl_res$final_hs,
    file.path(hotspot_dir, "Global_Hotspot_Summary_Ranked.csv"),
    row.names = FALSE
  )
}

# Save Plot
p <- plot(qtl_res)
if (!is.null(p)) {
  hotspot_dir <- file.path(output_path, "Hotspot_Analysis")
  ensure_dir(hotspot_dir)
  fname <- paste0("Global_Hotspot_Manhattan_Ranked_by_", qtl_res$params$rank_by, ".png")
  ggplot2::ggsave(file.path(hotspot_dir, fname), p, width = 16, height = 8, dpi = 600)
}

message("Results saved to: ", output_path)
