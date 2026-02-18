# Link to shared infrastructure (removed for package structure)

#' Determine QTL Specificity
#'
#' This function identifies whether a QTL is "Shared" or "Specific" by comparing
#' two datasets (e.g., different diets or sexes). A QTL is considered shared if
#' the same phenotype has a peak on the same chromosome within a specified distance.
#'
#' @param df_a A data frame containing QTL mapping results for the first group.
#' @param df_b A data frame containing QTL mapping results for the second group.
#' @param dist_kb Coordinate distance in kilobases to define shared peaks (default 4000).
#'
#' @return A list containing two data frames (a_final and b_final) with an added
#' `qtl_status` column.
#'
#' @importFrom dplyr rowwise mutate ungroup
#' @export
get_specificity <- function(df_a, df_b, dist_kb = 4000) {
  # Define Shared: Same phenotype on same Chr within 4Mb
  find_shared <- function(target, reference) {
    target |>
      dplyr::rowwise() |>
      dplyr::mutate(is_shared = any(reference$phenotype == phenotype &
        reference$qtl_chr == qtl_chr &
        abs(reference$qtl_pos - qtl_pos) <= (dist_kb / 1000))) |>
      dplyr::ungroup() |>
      dplyr::mutate(qtl_status = ifelse(is_shared, "Shared", "Specific"))
  }

  list(a_final = find_shared(df_a, df_b), b_final = find_shared(df_b, df_a))
}

#' Summarize QTL Specificity Results
#'
#' Provides a counts and average LOD summary of shared and specific QTL for a given group.
#'
#' @param df A data frame containing QTL mapping results with a `qtl_status` column.
#' @param group_label A string label for the group being summarized.
#'
#' @return A summary data frame with counts, unique metabolites, and average LOD.
#'
#' @importFrom dplyr group_by summarise n n_distinct mutate select
#' @export
summarize_qtl_specificity <- function(df, group_label) {
  summary <- df |>
    dplyr::group_by(qtl_status) |>
    dplyr::summarise(
      Count = dplyr::n(),
      Unique_Metabolites = dplyr::n_distinct(phenotype),
      Avg_LOD = mean(qtl_lod, na.rm = TRUE)
    ) |>
    dplyr::mutate(group = group_label) |>
    dplyr::select(group, qtl_status, Count, Unique_Metabolites, Avg_LOD)

  return(summary)
}

#' Generate Clean Manhattan Plot
#'
#' Creates a publication-quality Manhattan plot with GRCm39 coordinates,
#' highlighting shared vs specific QTL peaks.
#'
#' @param data_df A data frame containing QTL results and a `qtl_status` column.
#' @param dataset_name Title and filename for the plot.
#' @param output_folder Directory to save the resulting PNG.
#' @param pt_size Point size for the plot (default 7.0).
#'
#' @return A ggplot object.
#'
#' @importFrom dplyr mutate filter inner_join
#' @importFrom ggplot2 ggplot aes geom_point scale_fill_identity scale_x_continuous coord_cartesian theme_classic theme element_blank element_text labs ggsave
#' @export
generate_clean_manhattan <- function(data_df, dataset_name, output_folder, pt_size = 7.0) {
  # A. Sanitize Data
  df_plot <- data_df |>
    dplyr::mutate(
      Chr = as.character(qtl_chr),
      Chr = ifelse(Chr == "20", "X", Chr)
    ) |>
    dplyr::filter(Chr %in% names(chr_lens)) |>
    dplyr::inner_join(GLOBAL_MAP, by = "Chr") |>
    dplyr::mutate(BP_cum = offset + qtl_pos)

  # B. Calculate counts for subtitle
  n_cropped <- sum(df_plot$qtl_lod > 100)

  # C. The Plot
  p <- ggplot2::ggplot(df_plot, ggplot2::aes(x = BP_cum, y = qtl_lod)) +
    ggplot2::geom_point(
      data = dplyr::filter(df_plot, qtl_status == "Shared"),
      shape = 1, color = "black", size = pt_size, stroke = 1.0, alpha = 0.5
    ) +
    ggplot2::geom_point(
      data = dplyr::filter(df_plot, qtl_status == "Specific"),
      ggplot2::aes(fill = chr_col), shape = 21, color = "black",
      size = pt_size, stroke = 0.3, alpha = 0.9
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::scale_x_continuous(
      breaks = GLOBAL_MAP$center, labels = GLOBAL_MAP$Chr,
      limits = c(0, TOTAL_LEN), expand = c(0.005, 0.005)
    ) +
    ggplot2::coord_cartesian(ylim = c(0, 100)) +
    ggplot2::theme_classic(base_size = 18) +
    ggplot2::theme(
      legend.position = "top",
      panel.grid = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_text(size = 10, angle = 0),
      axis.title = ggplot2::element_text(face = "bold")
    ) +
    ggplot2::labs(
      title = paste("QTL Manhattan:", dataset_name),
      subtitle = paste("Solid = Unique | Open = Shared |", n_cropped, "peaks with LOD > 100 hidden"),
      x = "Chromosome",
      y = "LOD Score"
    )

  # Save and return
  ensure_dir(output_folder)
  ggplot2::ggsave(file.path(output_folder, paste0("Manhattan_", dataset_name, ".png")),
    p,
    width = 16, height = 6, dpi = 300
  )
  return(p)
}

#' Identify QTL Hotspots
#'
#' Groups traits into genomic clusters (hotspots) based on chromosomal proximity.
#'
#' @param df A master data frame containing combined QTL peaks.
#' @param gap_limit Maximum distance (Mb) between peaks to consider them part of the same cluster.
#'
#' @return A summary data frame listing clusters, trait counts, and trait names.
#'
#' @importFrom dplyr arrange group_by mutate lag first summarise n distinct
#' @export
identify_hotspots <- function(df, gap_limit) {
  df |>
    dplyr::arrange(group, qtl_chr, qtl_pos) |>
    dplyr::group_by(group, qtl_chr) |>
    dplyr::mutate(
      diff_pos = qtl_pos - dplyr::lag(qtl_pos, default = dplyr::first(qtl_pos)),
      new_cluster = ifelse(diff_pos > gap_limit, 1, 0),
      cluster_id = cumsum(new_cluster)
    ) |>
    dplyr::group_by(group, qtl_chr, cluster_id) |>
    dplyr::summarise(
      Start_Mb = min(qtl_pos),
      End_Mb = max(qtl_pos),
      Total_Traits = dplyr::n(),
      Traits_List = paste(unique(phenotype), collapse = "; "),
      n_liver_metab = sum(trait_class == "liver_metabolites_labeled"),
      n_plasma_metab = sum(trait_class == "plasma_metabolites"),
      n_liver_lipids = sum(trait_class == "liver_lipids"),
      n_clinical = sum(trait_class == "clinical_traits"),
      .groups = "drop"
    )
}

#' Run Comprehensive QTL Analysis
#'
#' Automates data loading, specificity analysis, hotspot identification, and visualization.
#'
#' @param phenotype_classes Character vector of phenotype classes to analyze.
#' @param qtl_model QTL model used (e.g., "additive").
#' @param input_dir Directory containing peak summary CSV files.
#' @param groups Character vector of groups (default c("HC", "HF", "female", "male")).
#' @param gap_limit Distance in Mb to group peaks into hotspots (default 4.0).
#' @param rank_by Hotspot ranking criteria ("Diversity" or "Density").
#' @param pt_size Point size for plots (default 7.0).
#'
#' @return An object of class `qtl_analysis`.
#'
#' @importFrom data.table fread
#' @importFrom dplyr select mutate bind_rows filter rowwise ungroup arrange group_by summarise n_distinct desc inner_join rename
#' @importFrom ggplot2 ggplot aes geom_rect geom_segment geom_point geom_text scale_fill_manual scale_shape_manual scale_x_continuous scale_y_continuous guides guide_legend labs theme_minimal theme element_blank ggsave
#' @importFrom utils write.csv head
#' @export
run_qtl_analysis <- function(phenotype_classes,
                             qtl_model = "additive",
                             input_dir,
                             groups = c("HC", "HF", "female", "male"),
                             gap_limit = 4.0,
                             rank_by = "Diversity",
                             pt_size = 7.0) {
  all_peaks <- list()
  qtl_summaries <- list()

  for (t_class in phenotype_classes) {
    message("Processing Trait Class: ", t_class)

    # Load data for each group
    dats <- list()
    for (grp in groups) {
      fname <- paste0("DO1200_", t_class, "_", grp, "_mice_", qtl_model, "_peaks.csv")
      fpath <- file.path(input_dir, fname)

      if (file.exists(fpath)) {
        df <- data.table::fread(fpath)
        dats[[grp]] <- df

        # Prepare for master peak list
        all_peaks[[paste0(t_class, "_", grp)]] <- df |>
          dplyr::select(phenotype, qtl_chr, qtl_pos, qtl_lod) |>
          dplyr::mutate(
            trait_class = t_class, group = grp,
            qtl_chr = as.character(qtl_chr),
            qtl_chr = ifelse(qtl_chr == "20", "X", qtl_chr)
          )
      }
    }

    # Run comparisons (Diet and Sex) if groups exist
    if (all(c("HC", "HF") %in% names(dats))) {
      diet_comp <- get_specificity(dats$HC, dats$HF)
      qtl_summaries[[paste0(t_class, "_HC")]] <- summarize_qtl_specificity(diet_comp$a_final, paste(t_class, "HC Diet"))
      qtl_summaries[[paste0(t_class, "_HF")]] <- summarize_qtl_specificity(diet_comp$b_final, paste(t_class, "HF Diet"))
    }

    if (all(c("female", "male") %in% names(dats))) {
      # Handle case mapping
      sex_comp <- get_specificity(dats$female, dats$male)
      qtl_summaries[[paste0(t_class, "_female")]] <- summarize_qtl_specificity(sex_comp$a_final, paste(t_class, "Female Sex"))
      qtl_summaries[[paste0(t_class, "_male")]] <- summarize_qtl_specificity(sex_comp$b_final, paste(t_class, "Male Sex"))
    }
  }

  # Final Summaries
  summary_table <- if (length(qtl_summaries) > 0) {
    dplyr::bind_rows(qtl_summaries)
  } else {
    NULL
  }

  # Hotspot Analysis
  final_hs <- NULL
  plot_data <- NULL
  top_10_hs <- NULL

  if (length(all_peaks) > 0) {
    master_peaks <- dplyr::bind_rows(all_peaks)
    all_clusters <- identify_hotspots(master_peaks, gap_limit = gap_limit)

    final_hs <- all_clusters |>
      dplyr::rowwise() |>
      dplyr::mutate(
        counts = list(c(n_liver_metab, n_plasma_metab, n_liver_lipids, n_clinical)),
        has_2_plus = any(unlist(counts) >= 2),
        has_other = sum(unlist(counts) > 0) >= 2
      ) |>
      dplyr::ungroup() |>
      dplyr::filter(has_2_plus & has_other) |>
      dplyr::select(-counts, -has_2_plus, -has_other) |>
      dplyr::arrange(dplyr::desc(Total_Traits))

    # Integrated Manhattan Plot
    plot_data <- master_peaks |>
      dplyr::inner_join(GLOBAL_MAP |> dplyr::rename(qtl_chr = Chr), by = "qtl_chr") |>
      dplyr::mutate(cum_pos = qtl_pos + offset)

    hotspots <- plot_data |>
      dplyr::arrange(qtl_chr, qtl_pos) |>
      dplyr::group_by(qtl_chr) |>
      dplyr::mutate(group = cumsum(c(1, diff(qtl_pos) > 2))) |>
      dplyr::group_by(qtl_chr, group) |>
      dplyr::summarise(
        Total_Traits = dplyr::n(),
        n_classes = dplyr::n_distinct(trait_class),
        cum_center = cum_pos[which.max(qtl_lod)],
        pos_at_max = qtl_pos[which.max(qtl_lod)],
        max_lod = max(qtl_lod),
        .groups = "drop"
      )

    top_10_hs <- if (rank_by == "Diversity") {
      hotspots |>
        dplyr::arrange(dplyr::desc(n_classes), dplyr::desc(Total_Traits)) |>
        utils::head(10)
    } else {
      hotspots |>
        dplyr::arrange(dplyr::desc(Total_Traits)) |>
        utils::head(10)
    }
  }

  res <- list(
    summary_table = summary_table,
    final_hs = final_hs,
    plot_data = plot_data,
    top_10_hs = top_10_hs,
    params = list(
      phenotype_classes = phenotype_classes,
      groups = groups,
      rank_by = rank_by,
      pt_size = pt_size
    )
  )
  class(res) <- "qtl_analysis"

  message("QTL analysis complete.")
  return(res)
}

#' Print QTL Analysis Result
#'
#' @param x An object of class `qtl_analysis`.
#' @param ... Extra arguments (ignored).
#'
#' @export
print.qtl_analysis <- function(x, ...) {
  cat("QTL Analysis Result Object\n")
  cat("--------------------------\n")
  cat("Trait Classes: ", paste(x$params$phenotype_classes, collapse = ", "), "\n")
  cat("Groups:        ", paste(x$params$groups, collapse = ", "), "\n")
  if (!is.null(x$final_hs)) {
    cat("Hotspots Found: ", nrow(x$final_hs), "\n")
  }
}

#' Summary of QTL Analysis
#'
#' @param object An object of class `qtl_analysis`.
#' @param ... Extra arguments (ignored).
#'
#' @return A data frame containing the QTL specificity summary.
#'
#' @export
summary.qtl_analysis <- function(object, ...) {
  return(object$summary_table)
}

#' Plot QTL Analysis
#'
#' @param x An object of class `qtl_analysis`.
#' @param ... Extra arguments (passed to ggsave if saving).
#'
#' @return A ggplot object.
#'
#' @importFrom ggplot2 ggplot aes geom_rect geom_segment geom_point geom_text scale_fill_manual scale_shape_manual scale_x_continuous scale_y_continuous guides guide_legend labs theme_minimal theme element_blank
#' @export
plot.qtl_analysis <- function(x, ...) {
  if (is.null(x$plot_data) || is.null(x$top_10_hs)) {
    warning("No plot data available.")
    return(NULL)
  }

  # Redefine colors/shapes inside or via global
  class_colors <- c(
    "clinical_traits" = "#984EA3", "liver_lipids" = "#4DAF4A",
    "liver_metabolites_labeled" = "#E41A1C", "plasma_metabolites" = "#377EB8"
  )
  group_shapes <- c("HC" = 21, "HF" = 24, "female" = 22, "male" = 23)

  top_10_hs <- x$top_10_hs
  top_10_hs$label <- paste0("Chr", top_10_hs$qtl_chr, ":", round(top_10_hs$pos_at_max, 1), "Mb")

  p <- ggplot2::ggplot(x$plot_data, ggplot2::aes(x = cum_pos, y = qtl_lod)) +
    ggplot2::geom_rect(
      data = GLOBAL_MAP |> dplyr::filter(dplyr::row_number() %% 2 == 0),
      ggplot2::aes(xmin = offset, xmax = offset + Length, ymin = 0, ymax = Inf),
      fill = "grey95", color = NA, inherit.aes = FALSE
    ) +
    ggplot2::geom_segment(
      data = top_10_hs,
      ggplot2::aes(
        x = cum_center, xend = cum_center,
        y = max_lod + 2, yend = 92
      ),
      color = "black", linetype = "dotted", linewidth = 0.75, alpha = 1.0, inherit.aes = FALSE
    ) +
    ggplot2::geom_point(ggplot2::aes(fill = trait_class, shape = group),
      size = 6, color = "black", stroke = 0.3, alpha = 0.7
    ) +
    ggplot2::geom_text(
      data = top_10_hs, ggplot2::aes(x = cum_center, y = 95, label = label),
      angle = 90, vjust = -0.5, size = 14 * 0.3,
      color = "black", fontface = "bold", inherit.aes = FALSE
    ) +
    ggplot2::scale_fill_manual(values = class_colors, name = "Trait Class:  ") +
    ggplot2::scale_shape_manual(values = group_shapes, name = "Group (Shape):  ") +
    ggplot2::scale_x_continuous(label = GLOBAL_MAP$Chr, breaks = GLOBAL_MAP$center, expand = c(0, 0)) +
    ggplot2::scale_y_continuous(limits = c(0, 105), breaks = seq(0, 100, 20)) +
    ggplot2::guides(
      fill = ggplot2::guide_legend(override.aes = list(shape = 21, size = 4)),
      shape = ggplot2::guide_legend(override.aes = list(fill = "grey70", size = 4))
    ) +
    ggplot2::labs(
      title = "Integrated Multi-Class Manhattan Plot",
      subtitle = paste("Points shaped by Group | Ranked by", x$params$rank_by),
      x = "Chromosome (GRCm39 Mb)", y = "LOD Score"
    ) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::theme(
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "bottom",
      legend.box = "vertical"
    )

  return(p)
}
