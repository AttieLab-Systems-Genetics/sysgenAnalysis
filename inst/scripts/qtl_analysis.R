# ===============================================================
# QTL Analysis Pipeline: Specificity & Hotspots
# ===============================================================

# 1. Setup Environment
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
run_qtl_analysis(
  phenotype_classes = trait_classes,
  qtl_model = "additive",
  input_dir = input_path,
  output_dir = output_path,
  groups = c("HC", "HF", "female", "male"),
  rank_by = "Diversity"
)
