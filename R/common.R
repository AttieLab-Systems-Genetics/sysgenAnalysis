#' sysgenAnalysis: Systems Genetics Analysis for Attie Lab
#'
#' @description
#' Routines for systems analysis, including trans-eQTL hotspot density calculation and visualization.
#'
#' @name sysgenAnalysis
#' @keywords internal
"_PACKAGE"

# ==============================================================================
# 1. GRCm39 Coordinate Configuration
# ==============================================================================

#' GRCm39 Chromosome Lengths
#' @export
chr_lens <- c(
  "1" = 195.15, "2" = 181.75, "3" = 159.75, "4" = 156.86, "5" = 151.76, "6" = 149.58,
  "7" = 144.99, "8" = 130.13, "9" = 124.36, "10" = 130.53, "11" = 121.97, "12" = 120.09,
  "13" = 120.88, "14" = 125.14, "15" = 104.07, "16" = 98.01, "17" = 95.29, "18" = 90.72,
  "19" = 61.42, "X" = 169.48, "Y" = 91.45, "M" = 0.016
)

#' Global Coordinate Map for plotting
#'
#' @importFrom dplyr mutate lag
#' @export
GLOBAL_MAP <- data.frame(Chr = names(chr_lens), Length = as.numeric(chr_lens)) |>
  dplyr::mutate(
    offset = dplyr::lag(cumsum(Length), default = 0),
    center = offset + Length / 2,
    chr_col = rep(c("royalblue3", "orange2"), length.out = length(chr_lens))
  )

#' Total Length of the genome in Mb
#' @export
TOTAL_LEN <- sum(GLOBAL_MAP$Length)

# ==============================================================================
# 2. Standardized Color Palettes
# ==============================================================================
#' Color Palette for Diets and Sexes
#' @export
context_colors <- c(
  "HC Diet" = "#4DAF4A",
  "HF Diet" = "#984EA3",
  "High Fat" = "#984EA3",
  "High Carbohydrate" = "#4DAF4A",
  "Female" = "#E41A1C",
  "Male" = "#377EB8"
)

#' Color Palette for Trait Classes
#' @export
trait_class_colors <- c(
  "liver_metabolites_labeled" = "#E41A1C",
  "plasma_metabolites" = "#377EB8",
  "liver_lipids" = "#4DAF4A",
  "clinical_traits" = "#984EA3"
)

# ==============================================================================
# 3. File System Helpers
# ==============================================================================

#' Get Research Data Directory
#'
#' Resolves the path to the main research directory based on the operating system.
#' Mac: "/Volumes", Windows: "W:".
#'
#' @return The absolute path to the main data directory.
#' @export
research_dir <- function() {
  research_drive <- ifelse(Sys.info()["sysname"] == "Darwin", "/Volumes", "W:")
  data_dir <- file.path(research_drive, "mkeller3/General/main_directory")
  return(data_dir)
}

#' Ensure Directory Exists
#'
#' A helper to create nested directories if they don't already exist.
#'
#' @param path The directory path to check/create.
#' @export
ensure_dir <- function(path) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }
}

#' Standardized Positional Factor
#'
#' Ensures chromosomes are ordered correctly as factors for plotting.
#'
#' @param chr_vector A vector of chromosome labels.
#' @export
clean_chr_factor <- function(chr_vector) {
  factor(chr_vector, levels = c(1:19, "X", "Y", "M"))
}
