# ==========================================
# Trans-eQTL Hotspot Analysis Pipeline
# ==========================================

# 1. Setup Environment
library(sysgenAnalysis)

# 2. Configuration
data_dir <- research_dir()
save_dir <- "byandell/output"

input_path <- file.path(data_dir, "annotated_peak_summaries")
base_output <- file.path(save_dir, "eQTL_Analysis")
output_path <- file.path(base_output, "Hotspots")

classes <- c("liver_genes") # Can be extended to more classes

# 3. Execution
hs_res <- run_hotspot_analysis(
  phenotype_classes = classes,
  qtl_model = "additive",
  input_dir = input_path,
  groups = c("HC", "HF", "female", "male"),
  threshold = 15
)

# 4. Results & Persistence
print(hs_res)

# Save Differential Hotspot Traits
diff_summaries <- summary(hs_res)
if (length(diff_summaries) > 0) {
  diff_dir <- file.path(output_path, "Differential_Hotspots")
  ensure_dir(diff_dir)
  for (name in names(diff_summaries)) {
    readr::write_csv(
      diff_summaries[[name]],
      file.path(diff_dir, paste0(name, "_Hotspot_Traits.csv"))
    )
  }
}

# Save Plots
plots <- plot(hs_res)
if (length(plots) > 0) {
  ensure_dir(output_path)
  for (name in names(plots)) {
    ggplot2::ggsave(file.path(output_path, paste0(name, ".png")),
      plot = plots[[name]], width = 14, height = 7
    )
  }
}

message("Hotspot analysis results saved to: ", output_path)
