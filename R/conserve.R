#' SNP Conserve Analysis
#'
#' @description
#' Functions for SNP prioritization using genomic conservation scores and SIFT.
#'
#' @name conserve
NULL

# Resolve non-standard evaluation warnings
utils::globalVariables(c(
    "variant_chr", "variant_chr_clean", "variant_pos", "variant_pos_bp",
    "phastCons_score", "canonical_transcript", "sift_score", "min_sift_score",
    "priority_score", "priority_score_pure_conservation", "phenotype",
    "qtl_lod", "qtl_chr", "qtl_pos", "variant_lod", "rs_number", "aa_pos",
    "aa_change", "csq", "impact", "exon_num", "intron_num", "feature_strand",
    "variant_id", "gene_symbol", "trait_class", "trait_class_count",
    "trait_classes", "specific_traits", "avg_phastCons", "variant_pos_mbp",
    "max_priority", "max_variant_lod", "chr_full", "sort_val", "offset",
    "cum_pos", "trait_count", "center", "Length", "trait_count"
))

#' Run SNP Conservation Analysis for a Trait
#'
#' Prioritizes SNPs for a specific trait by querying phastCons conservation scores
#' and incorporating SIFT scores if available.
#'
#' @param input_path Path to the input SNP CSV file.
#' @param trait_name Name of the trait being analyzed.
#'
#' @return A data frame of prioritized SNPs.
#'
#' @importFrom IRanges IRanges
#' @importFrom GenomicRanges GRanges
#' @importFrom GenomicScores getGScores score
#' @importFrom AnnotationHub AnnotationHub setAnnotationHubOption
#' @importFrom GenomeInfoDb seqinfo seqlengths
#' @import phastCons35way.UCSC.mm39
#' @importFrom stats na.omit
#' @export
run_trait_conservation <- function(input_path, trait_name) {
    message("--- Processing Trait: ", trait_name, " ---")

    # Increase download limit for large genome-wide packages
    AnnotationHub::setAnnotationHubOption("MAX_DOWNLOADS", 100)

    # Load phast_mm39 (ideally should be cached or passed, but keeping it simple for now)
    phast_mm39 <- GenomicScores::getGScores("phastCons35way.UCSC.mm39")

    # Load Data
    message("Loading SNP data...")
    snps <- data.table::fread(input_path)

    # Ensure chromosome is character and in 'chrN' format
    snps[, variant_chr_clean := as.character(variant_chr)]
    snps[!startsWith(variant_chr_clean, "chr"), variant_chr_clean := paste0("chr", variant_chr_clean)]

    # Coordinates handle (Mb to bp if needed)
    if (max(snps$variant_pos, na.rm = TRUE) < 2000) {
        snps[, variant_pos_bp := as.integer(round(variant_pos * 1e6))]
    } else {
        snps[, variant_pos_bp := as.integer(variant_pos)]
    }

    # Fetch scores
    message("Querying conservation scores...")
    snp_ranges <- GenomicRanges::GRanges(
        seqnames = snps$variant_chr_clean,
        ranges = IRanges::IRanges(start = snps$variant_pos_bp, width = 1),
        genome = "mm39"
    )
    snps[, phastCons_score := GenomicScores::score(phast_mm39, snp_ranges)]

    # Uncollapse logic
    collapsed_cols <- c(
        "csq", "impact", "gene_id", "gene_symbol", "transcript_id",
        "transcript_type", "canonical_transcript", "aa_pos", "aa_change",
        "sift_score", "exon_num", "intron_num", "feature_strand"
    )

    split_clean <- function(x) {
        if (is.na(x) || x == "" || x == "-") {
            return(character(0))
        }
        trimws(unlist(strsplit(as.character(x), ";")))
    }

    uncollapsed_list <- list()
    for (i in seq_len(nrow(snps))) {
        point_data <- snps[i, !colnames(snps) %in% collapsed_cols, with = FALSE]
        splits <- lapply(snps[i, collapsed_cols, with = FALSE], split_clean)
        n_isoforms <- max(sapply(splits, length), 1)
        splits_rect <- lapply(splits, function(v) {
            if (length(v) == 0) {
                return(rep(NA_character_, n_isoforms))
            }
            if (length(v) < n_isoforms) {
                return(c(v, rep(v[length(v)], n_isoforms - length(v))))
            }
            return(v)
        })
        iso_dt <- data.table::as.data.table(splits_rect)
        iso_dt <- cbind(iso_dt, point_data)
        uncollapsed_list[[i]] <- iso_dt
    }
    snps_long <- data.table::rbindlist(uncollapsed_list, fill = TRUE)

    # Clean columns
    snps_long[, canonical_transcript := as.integer(canonical_transcript)]
    snps_long[is.na(canonical_transcript), canonical_transcript := 0]

    get_min_sift <- function(s) {
        vals <- as.numeric(unlist(strsplit(as.character(s), "[ ,]+")))
        if (length(vals) == 0 || all(is.na(vals))) {
            return(NA)
        }
        min(vals, na.rm = TRUE)
    }
    snps_long[, min_sift_score := sapply(sift_score, get_min_sift)]

    # Scores
    snps_long[, priority_score := data.table::fcoalesce(phastCons_score, 0) - data.table::fcoalesce(min_sift_score, 1.0)]
    # Handle cases where min_sift_score might be Inf (introduced by aggregation later or if already present)
    snps_long[is.infinite(priority_score), priority_score := data.table::fcoalesce(phastCons_score, 0) - 1.0]

    snps_long[, priority_score_pure_conservation := data.table::fcoalesce(phastCons_score, 0)]

    # Collapse to SNP/Gene
    pick_best <- function(values, is_canonical) {
        if (any(is_canonical == 1, na.rm = TRUE)) {
            res <- values[which(is_canonical == 1)[1]]
        } else {
            res <- values[1]
        }
        if (length(res) == 0 || is.na(res) || res == "") {
            return("-")
        }
        return(res)
    }

    snps_final <- snps_long[, .(
        phenotype = phenotype[1],
        qtl_lod = qtl_lod[1],
        qtl_chr = qtl_chr[1],
        qtl_pos = qtl_pos[1],
        variant_lod = variant_lod[1],
        rs_number = rs_number[1],
        variant_chr = gsub("chr", "", variant_chr_clean[1]),
        variant_pos = variant_pos[1],
        variant_pos_bp = variant_pos_bp[1],
        aa_pos = pick_best(aa_pos, canonical_transcript),
        aa_change = pick_best(aa_change, canonical_transcript),
        csq = paste(unique(stats::na.omit(csq)), collapse = "; "),
        impact = paste(unique(stats::na.omit(impact)), collapse = "; "),
        exon_num = paste0("'", pick_best(exon_num, canonical_transcript)),
        intron_num = paste0("'", pick_best(intron_num, canonical_transcript)),
        feature_strand = pick_best(feature_strand, canonical_transcript),
        phastCons_score = phastCons_score[1],
        min_sift_score = (function(val) {
            m <- min(val, na.rm = TRUE)
            if (is.infinite(m)) {
                return(-1)
            }
            return(m)
        })(min_sift_score),
        priority_score = priority_score[1],
        priority_score_pure_conservation = priority_score_pure_conservation[1]
    ), by = .(variant_id, gene_symbol)]

    data.table::setorder(snps_final, -priority_score, -qtl_lod)

    return(snps_final)
}

#' Run Global SNP Conservation Hotspot Analysis
#'
#' Aggregates results from multiple traits to identify hotspots where high-priority
#' variants are shared across trait classes.
#'
#' @param traits_to_process A named list where names are trait classes and values are file paths.
#'
#' @return An object of class `conserve_analysis`.
#'
#' @importFrom data.table rbindlist uniqueN setorder
#' @export
run_conserve_analysis <- function(traits_to_process) {
    all_results <- list()

    for (t_name in names(traits_to_process)) {
        all_results[[t_name]] <- run_trait_conservation(traits_to_process[[t_name]], t_name)
    }

    message("--- Running Global Hotspot Analysis ---")
    master_dt <- data.table::rbindlist(all_results, idcol = "trait_class")

    # Hotspot calculation
    hotspots <- master_dt[, .(
        trait_class_count = data.table::uniqueN(trait_class),
        trait_classes = paste(sort(unique(trait_class)), collapse = "; "),
        specific_traits = paste(sort(unique(phenotype)), collapse = "; "),
        max_priority = max(priority_score),
        avg_phastCons = mean(phastCons_score),
        max_variant_lod = max(variant_lod),
        variant_chr = variant_chr[1],
        variant_pos_bp = variant_pos_bp[1],
        variant_pos_mbp = variant_pos[1],
        rs_number = rs_number[1],
        consequence = csq[1],
        impact = impact[1],
        aa_pos = aa_pos[1],
        aa_change = aa_change[1],
        exon_num = exon_num[1],
        intron_num = intron_num[1],
        qtl_chr = qtl_chr[1],
        qtl_pos = qtl_pos[1]
    ), by = .(variant_id, gene_symbol)]

    # Filter for variants in more than one trait class
    hotspots <- hotspots[trait_class_count > 1]
    data.table::setorder(hotspots, -trait_class_count, -max_priority)

    res <- list(
        all_results = all_results,
        hotspots = hotspots,
        traits_to_process = traits_to_process
    )
    class(res) <- "conserve_analysis"

    message("SNP conservation analysis complete.")
    return(res)
}

#' Print SNP Conservation Analysis Result
#'
#' @param x An object of class `conserve_analysis`.
#' @param ... Extra arguments (ignored).
#'
#' @export
print.conserve_analysis <- function(x, ...) {
    cat("SNP Conservation Analysis Result\n")
    cat("-------------------------------\n")
    cat("Trait Classes Analyzed: ", paste(names(x$all_results), collapse = ", "), "\n")
    cat("Global Hotspots Found:  ", nrow(x$hotspots), "\n")
}

#' Summary of SNP Conservation Analysis
#'
#' @param object An object of class `conserve_analysis`.
#' @param ... Extra arguments (ignored).
#'
#' @return A list of trait-level and global summaries.
#'
#' @export
summary.conserve_analysis <- function(object, ...) {
    trait_summary <- lapply(object$all_results, function(df) {
        list(count = nrow(df), max_priority = max(df$priority_score, na.rm = TRUE))
    })

    global_summary <- list(
        total_hotspots = nrow(object$hotspots),
        max_trait_overlap = if (nrow(object$hotspots) > 0) max(object$hotspots$trait_class_count) else 0
    )

    return(list(traits = trait_summary, global = global_summary))
}

#' Plot SNP Conservation Analysis
#'
#' Generates a Manhattan plot for the global hotspots.
#'
#' @param x An object of class `conserve_analysis`.
#' @param trait_name Optional. If provided, plots the Manhattan for a specific trait instead of global hotspots.
#' @param ... Extra arguments (ignored).
#'
#' @return A ggplot object.
#'
#' @importFrom ggplot2 ggplot aes geom_rect geom_point scale_color_gradientn scale_x_continuous theme_minimal labs theme element_blank element_text
#' @importFrom data.table copy data.table merge.data.table shift fcase
#' @importFrom GenomicScores getGScores
#' @importFrom GenomeInfoDb seqinfo seqlengths
#' @export
plot.conserve_analysis <- function(x, trait_name = NULL, ...) {
    # Load genome background
    phast_mm39 <- GenomicScores::getGScores("phastCons35way.UCSC.mm39")
    si <- GenomeInfoDb::seqinfo(phast_mm39)
    chr_lengths_raw <- GenomeInfoDb::seqlengths(si)

    main_chrs <- c(paste0("chr", 1:19), "chrX", "chrY")
    chr_lengths <- chr_lengths_raw[names(chr_lengths_raw) %in% main_chrs]

    chr_info <- data.table::data.table(chr = names(chr_lengths), length = as.numeric(chr_lengths))
    chr_info[, chr_num := gsub("chr", "", chr)]
    chr_info[, sort_val := data.table::fcase(
        chr_num == "X", 20,
        chr_num == "Y", 21,
        default = as.numeric(chr_num)
    )]
    data.table::setorder(chr_info, sort_val)
    chr_info[, offset := cumsum(data.table::shift(length, fill = 0))]
    chr_info[, center := offset + (length / 2)]

    if (is.null(trait_name)) {
        # Global Hotspot Plot
        if (nrow(x$hotspots) == 0) {
            warning("No hotspots to plot.")
            return(NULL)
        }

        plot_data <- data.table::copy(x$hotspots)
        plot_data[, chr_full := paste0("chr", variant_chr)]
        plot_data <- plot_data[chr_full %in% names(chr_lengths)]
        plot_data <- data.table::merge.data.table(plot_data, chr_info[, .(chr, offset)], by.x = "chr_full", by.y = "chr")
        plot_data[, cum_pos := (variant_pos_bp + offset) / 1e6]

        p <- ggplot2::ggplot() +
            ggplot2::geom_rect(
                data = chr_info[sort_val %% 2 == 1],
                aes(xmin = offset / 1e6, xmax = (offset + length) / 1e6, ymin = -Inf, ymax = Inf),
                fill = "grey95", alpha = 0.5
            ) +
            ggplot2::geom_point(
                data = plot_data,
                aes(x = cum_pos, y = trait_class_count, color = max_priority, size = max_variant_lod),
                alpha = 0.8
            ) +
            ggplot2::scale_color_gradientn(colors = c("blue", "orange", "red"), name = "Max Priority") +
            ggplot2::scale_x_continuous(label = chr_info$chr_num, breaks = chr_info$center / 1e6, expand = c(0, 0)) +
            ggplot2::theme_minimal() +
            ggplot2::labs(
                title = "Multi-Trait Co-mapping Hotspots",
                subtitle = "Y: Number of Trait Classes sharing a High Priority Variant",
                x = "Chromosome", y = "Number of Traits (Co-mapping Frequency)",
                size = "Max Variant LOD"
            ) +
            ggplot2::theme(
                panel.grid.minor = ggplot2::element_blank(),
                panel.grid.major.x = ggplot2::element_blank(),
                axis.text.x = ggplot2::element_text(size = 8),
                legend.position = "right"
            )
    } else {
        # Trait-specific Manhattan Plot
        if (!trait_name %in% names(x$all_results)) {
            stop("Trait not found in analysis results.")
        }

        plot_data <- data.table::copy(x$all_results[[trait_name]])
        plot_data <- plot_data[!is.na(priority_score)]
        plot_data[, chr_full := paste0("chr", variant_chr)]
        plot_data <- plot_data[chr_full %in% names(chr_lengths)]
        plot_data <- data.table::merge.data.table(plot_data, chr_info[, .(chr, offset)], by.x = "chr_full", by.y = "chr")
        plot_data[, cum_pos := (variant_pos_bp + offset) / 1e6]

        p <- ggplot2::ggplot() +
            ggplot2::geom_rect(
                data = chr_info[sort_val %% 2 == 1],
                aes(xmin = offset / 1e6, xmax = (offset + length) / 1e6, ymin = -Inf, ymax = Inf),
                fill = "grey95", alpha = 0.5
            ) +
            ggplot2::geom_point(
                data = plot_data,
                aes(x = cum_pos, y = priority_score, color = phastCons_score, size = variant_lod, alpha = priority_score)
            ) +
            ggplot2::scale_color_gradientn(colors = c("blue", "green", "orange", "red"), name = "Conservation") +
            ggplot2::scale_alpha_continuous(range = c(0.1, 1.0), guide = "none") +
            ggplot2::scale_x_continuous(label = chr_info$chr_num, breaks = chr_info$center / 1e6, expand = c(0, 0)) +
            ggplot2::theme_minimal() +
            ggplot2::labs(
                title = paste("Manhattan Plot:", trait_name),
                subtitle = "X: Genome-wide (Mbp) | Alpha: Priority",
                x = "Chromosome", y = "Combined Priority Score",
                size = "Variant LOD"
            ) +
            ggplot2::theme(
                panel.grid.minor = ggplot2::element_blank(),
                panel.grid.major.x = ggplot2::element_blank(),
                axis.text.x = ggplot2::element_text(size = 8),
                legend.position = "right"
            )
    }

    return(p)
}

#' Read SNP Conservation Analysis Results from CSV
#'
#' Reconstructs a `conserve_analysis` object from saved CSV files.
#'
#' @param base_out Path to the directory containing the saved SNP conservation CSVs.
#'
#' @return An object of class `conserve_analysis`.
#'
#' @importFrom data.table fread
#' @export
read_conserve_analysis <- function(base_out) {
    # 1. Load Global Hotspots
    hs_file <- file.path(base_out, "global_hotspot_variants.csv")
    if (!file.exists(hs_file)) {
        stop("Hotspot CSV not found in: ", base_out)
    }
    hotspots <- data.table::fread(hs_file)

    # 2. Load Trait-Specific Results
    all_results <- list()
    # We can identify trait directories as they contain 'prioritized_*.csv'
    trait_dirs <- list.dirs(base_out, full.names = TRUE, recursive = FALSE)

    for (d in trait_dirs) {
        t_name <- basename(d)
        csv_file <- file.path(d, paste0("prioritized_", t_name, "_snps.csv"))
        if (file.exists(csv_file)) {
            all_results[[t_name]] <- data.table::fread(csv_file)
        }
    }

    # 3. Reconstruct S3 Object
    res <- list(
        all_results = all_results,
        hotspots = hotspots
    )
    class(res) <- "conserve_analysis"
    return(res)
}
