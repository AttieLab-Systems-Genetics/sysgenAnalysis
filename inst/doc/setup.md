# Setup commands

```
setup_environment <- function() {
  # 1. Define Paths
  # Note: Since you are running this locally, ensure the input path is accessible
  input_dir  <- "/Volumes/mkeller3/General/main_directory/annotated_peak_summaries"
  output_dir <- "/Users/adattie/Library/CloudStorage/Box-Box/R_stuff/Output files"
}
```

to change the source data for correlation analysis.

```
# Change "GLUTARYLCARNITINE" to "MALONATE" or any other trait!
target_metab <- names(metab_data)[grep("MALONATE", names(metab_data), ignore.case = TRUE)[1]]
```

conversion instructions.

## How to implement:

1.	Save the code below as a separate R file (e.g., Fix_My_Paths.R).
2.	Every time you get a new script from your colleague (e.g., New_Analysis.R),
just change the target_script variable in the code below and run it.

```
# 1. Provide the name of the script you just received 
target_script <- "New_Colleague_Script.R"
# 2. Define the search and replace patterns
win_input <- "W:/General/main_directory/annotated_peak_summaries"
mac_input <- "/Volumes/mkeller3/General/main_directory/annotated_peak_summaries"
win_output <- "C:/Users/mkeller3/Desktop/QTL_Differential_Analysis"
mac_output <- "/Users/adattie/Library/CloudStorage/Box-Box/R_stuff/Output files"
# 3. Read the script, swap the paths, and save a "Mac version"
if(file.exists(target_script)) {
    script_content <- readLines(target_script)
    fixed_content <- script_content %>%
    gsub(win_input, mac_input, ., fixed = TRUE) %>%
    gsub(win_output, mac_output, ., fixed = TRUE)
    mac_script_name <- paste0("MAC_", target_script)
    writeLines(fixed_content, mac_script_name)
    message("Success! A Mac-compatible version has been created: ", mac_script_name)
    # Optional: Uncomment the line below to run the script immediately
    # source(mac_script_name)
} else {
    message("Error: Could not find the file '", target_script, "'. Make sure it's in your current R folder.")
}
```

## Pro-Tip for Mac/Windows Collaboration
If you and your colleague want to use the same file without editing, you can add this "Smart Path" block at the very top of all your scripts. It detects which computer is running the code and sets the paths automatically:

```
# Check OS and set paths
if (Sys.info()["sysname"] == "Darwin") {
  # MAC PATHS
  input_dir  <- "/Volumes/mkeller3/General/main_directory/annotated_peak_summaries"
  output_dir <- "/Users/adattie/Library/CloudStorage/Box-Box/R_stuff/Output files"
} else {
  # WINDOWS PATHS
  input_dir  <- "W:/General/main_directory/annotated_peak_summaries"
  output_dir <- "C:/Users/mkeller3/Desktop/QTL_Differential_Analysis"
}
```
