# Script Transformation Prompt

**Goal**: Refactor a monolithic analysis script into a modular R package structure.

**Instructions**:

1. **Extract Functions**: Move all logical units (data processing, analysis, plotting) into `R/[basename].R`.
    - Document each function with **Roxygen2** syntax (including `@param`, `@return`, and `@export`).
    - Use R native pipes (`|>`) and explicit namespace calls (e.g., `dplyr::mutate`).
    - Centralize shared constants (like coordinate maps) if not already in `common.R`.

2. **Create Entry Script**: Create an execution script `inst/scripts/[basename]_analysis.R`.
    - Use it as a clean entry point that calls the functions defined in `R/`.
    - Handle environment setup, file paths, and high-level execution flow here.

3. **Return S3 Objects**: Refactor the main "run" function to return an S3 object of class `[basename]_analysis`.
    - Implement `print`, `summary`, and `plot` methods in `R/[basename].R`.
    - Move file-saving logic (`write.csv`, `ggsave`) out of the functions and into the entry script.

**Requested Files**:

- `R/[basename].R`
- `inst/scripts/[basename]_analysis.R`
- `inst/scripts/[basename]_analysis.qmd` (Quarto version)
