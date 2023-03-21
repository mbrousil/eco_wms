# Load packages required to define the pipeline:
library(targets)

tar_option_set(
  # By default these packages will be loaded for each target. Can be overridden
  # for each target if desired
  packages = c("tidyverse")
)

# By default, runs the R script(s) in the R/ folder with your custom functions
tar_source()

# List of targets in the workflow
list(
  
  # Arguments included in first use of tar_target()
  tar_target(name = sample_events,
             command = read_csv("data/sample_events.csv")),
  
  tar_target(sample_weather,
             read_csv("data/sample_weather.csv")),
  
  tar_target(merged_dataset,
             full_join(x = sample_events, y = sample_weather, by = "date")),
  
  # Use of custom function to store code outside of main _targets.R file (optional)
  tar_target(exploratory_plot,
             make_exploratory_plot(dataset = merged_dataset)),
  
  tar_target(linear_model,
             lm(counts ~ temp_c + precip_cm, data = merged_dataset)),
  
  tar_target(output_table,
             tidy(linear_model),
             packages = c("broom"))
  
)
