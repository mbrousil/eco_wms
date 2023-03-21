library(tidyverse)
library(broom)

# Load datasets
sample_events <- read_csv("data/sample_events.csv")

sample_weather <- read_csv("data/sample_weather.csv")

# Merge datasets into one dataframe
merged_dataset <- full_join(x = sample_events, y = sample_weather, by = "date")

# Exploratory plot
exploratory_plot <- merged_dataset %>%
  ggplot() +
  geom_point(aes(x = temp_c, y = counts, color = precip_cm)) +
  theme_bw()

# Construct a simple linear model and generate a summary table
linear_model <- lm(counts ~ temp_c + precip_cm, data = merged_dataset)

output_table <- tidy(linear_model)