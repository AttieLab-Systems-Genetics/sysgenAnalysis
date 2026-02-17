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
run_hotspot_analysis(
  phenotype_classes = classes,
  qtl_model = "additive",
  input_dir = input_path,
  output_dir = output_path,
  groups = c("HC", "HF", "female", "male"),
  threshold = 15
)
