# byandell Analysis Folder

This folder contains R scripts and documentation for QTL and hotspot analysis.
It also includes ideas on how to organize scripts and results in a way that
is easy to revisit and expand over time.
A useful reference is [Getting Started with Google Antigravity](https://codelabs.developers.google.com/getting-started-google-antigravity).

## Project and Folder Organization

- What is the best way to organize files in folder `R_stuff` and its subfolders?
- How to keep project descriptions, code and results together?
- How to develop README files that are useful for both humans and AI?
- How to use AI to help with this organization?

## Analysis files and their documentation

### Files to Source

Before running any analysis, please source these files to set up the environment and load shared functions:

- [dir.R](dir.R): Sets up directory paths.
- [common.R](common.R): Contains shared helper functions and GRCm39 coordinate configurations.

### Analysis Pipelines

The main analysis pipelines are contained in the following scripts:

- [qtl_analysis.R](qtl_analysis.R): Pipeline for QTL analysis.
- [hotspot_analysis.R](hotspot_analysis.R): Pipeline for hotspot analysis.

### Documentation

Refer to these documents for more information:

- [initial_pipeline.md](initial_pipeline.md): Original pipeline description.
- [setup.md](setup.md): Setup instructions.
- [walkthrough.md](walkthrough.md): Documented walkthrough of the analysis process.
