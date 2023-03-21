# This script generates sample datasets for use in both pipeline and non-pipeline
# examples

library(tidyverse)

# Example data:
sample_events <- tibble(
  date = c("2022-05-04", "2022-05-06", "2022-05-11", "2022-05-17", "2022-05-18",
           "2022-05-22", "2022-05-23", "2022-05-27", "2022-05-28", "2022-05-30"),
  counts = c(79, 68, 64, 89, 89, 87, 104, 79, 75, 84)
)

# Export
write_csv(x = sample_events,
          file = "data/sample_events.csv")

# Example data:
sample_weather <- tibble(
  date = c("2022-05-04", "2022-05-06", "2022-05-11", "2022-05-17", "2022-05-18",
           "2022-05-22", "2022-05-23", "2022-05-27", "2022-05-28", "2022-05-30"),
  temp_c = c(16.1, 16.1, 13.9, 18.3, 17.8, 18.9, 22.2, 19.4, 16.1, 17.8),
  precip_cm = c(0, 0.8, 0.3, 0, 0, 1, 1, 1.3, 0, 0)
)

# Export
write_csv(x = sample_weather,
          file = "data/sample_weather.csv")
