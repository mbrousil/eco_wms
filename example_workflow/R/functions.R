# A custom function to create an exploratory plot of the merged dataset
make_exploratory_plot <- function(dataset){
  
  dataset %>%
    ggplot() +
    geom_point(aes(x = temp_c, y = counts, color = precip_cm)) +
    theme_bw()
  
}