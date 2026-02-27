# Notes on Package

## Running of Workflows

Many workflows are one and done;
tweeking (think basename = `conserve` robustness) should be done on original script.
That is, one prompt
([walkthrough.md#workflow-prompt](walkthrough.md#workflow-prompt))
for all workflows.

- Consider how to set up test run.
- Production vs exploration workflows
- Use scripts/analyze_[basename].R for production

## Exploring Results of Workflows

This may be fine-tuned to individual workflows.
Use Quarto and make them dynamic.

- Adapt scripts/explore_[basename].qmd to explore saved tables (CSV).
- Document how this is adapted in that Quarto document.

Issues

- `plot.qtl_analysis` element `plot_data` uses `cum_pos` for position
rather than using qtl2::plot.scan1.
- `qtl_chr` in same element is char rather than factor, so need
something like the following:

```
all_chrs <- levels(reorder(qtl_res$plot_data$qtl_chr,
                             qtl_res$plot_data$cum_pos))
```

