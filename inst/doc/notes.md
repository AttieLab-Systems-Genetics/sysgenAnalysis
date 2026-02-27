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
Use Quarto and try to make them dynamic.

- Adapt scripts/explore_[basename].qmd to explore saved plots (PNG) and tables (CSV).
- Document how this is adapted in that Quarto document.

render_explore for dynamic document does not use output_dir. Somehow update how this works.
