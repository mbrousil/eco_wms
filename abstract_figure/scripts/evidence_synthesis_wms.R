# Script for word frequency enumeration, figure 2

library(tidyverse)
library(bibliometrix)
library(tm)
library(ggnewscale)
library(ggpubr)

# DOI: https://doi.org/10.6084/m9.figshare.22307494.v1
df_wide <- convert2df(file = "https://figshare.com/ndownloader/files/39680341",
                      format = "plaintext")

df_wide_subsample <- df_wide %>%
  filter(!is.na(PY)) %>%
  mutate(PY_group = case_when(PY < 2000 ~ "pre_00",
                              PY >= 2000 & PY < 2010 ~ "2000_2010",
                              PY >= 2010 ~ "2010_2022")) %>%
  slice_sample(prop = 0.20, weight_by = as.factor(PY_group)) %>%
  select(PY, DI, TI) %>%
  rownames_to_column(var = "pub_reference")

# First create text_in with only the abstracts
text_in <- df_wide$AB
# Remove NAs
text_in <- text_in[which(is.na(text_in) == FALSE)]
# For these procedures, object needs to be of class Corpus
text0 <- Corpus(VectorSource(text_in))
# Various text processing steps.
text <- TermDocumentMatrix(text0, 
                           control = 
                             list(removePunctuation = TRUE,
                                  stopwords = TRUE,
                                  tolower = TRUE,
                                  stemming = FALSE,
                                  removeNumbers = TRUE,
                                  bounds = list(global = c(1, Inf)))) 

ft <- findFreqTerms(text, lowfreq = 20, highfreq = Inf)

ft_matrix <- as.matrix(text[ft, ]) 

sorted_matrix <- sort(apply(ft_matrix, 1, sum), decreasing = TRUE) %>%
  data.frame()

life_sciences <- c("BIOCHEMISTRY & MOLECULAR BIOLOGY",
                   "MATHEMATICAL & COMPUTATIONAL BIOLOGY",
                   "NEUROSCIENCES & NEUROLOGY", "MICROBIOLOGY",
                   "PHYSIOLOGY", "ENTOMOLOGY", "GENETICS & HEREDITY", 
                   "MARINE & FRESHWATER BIOLOGY", "ZOOLOGY",
                   "CELL BIOLOGY")
physical_sciences <- c("ASTRONOMY & ASTROPHYSICS", "PHYSICS",
                       "NUCLEAR SCIENCE & TECHNOLOGY", "OPTICS",
                       "IMAGING SCIENCE & PHOTOGRAPHIC TECHNOLOGY",
                       "ACOUSTICS", "MECHANICS")
earth_environmental_sciences <- c("GEOLOGY", 
                                  "METEOROLOGY & ATMOSPHERIC SCIENCES", 
                                  "ENVIRONMENTAL SCIENCES & ECOLOGY",
                                  "FORESTRY", "PHYSICAL GEOGRAPHY",
                                  "REMOTE SENSING", "OCEANOGRAPHY",
                                  "GEOCHEMISTRY & GEOPHYSICS")
engineering <- c("COMPUTER SCIENCE", 
                 "TELECOMMUNICATIONS", "ENGINEERING",
                 "BIOTECHNOLOGY & APPLIED MICROBIOLOGY", "MATERIALS SCIENCE",
                 "WATER RESOURCES", "CONSTRUCTION & BUILDING TECHNOLOGY",
                 "ENERGY & FUELS")
medical_sciences <- c("INSTRUMENTS & INSTRUMENTATION", 
                      "HEALTH CARE SCIENCES & SERVICES",
                      "MEDICAL INFORMATICS", 
                      "DENTISTRY, ORAL SURGERY & MEDICINE",
                      "MEDICAL LABORATORY TECHNOLOGY", "ONCOLOGY",
                      "PHARMACOLOGY & PHARMACY", "INFECTIOUS DISEASES",
                      "LIFE SCIENCES & BIOMEDICINE - OTHER TOPICS", 
                      "PUBLIC, ENVIRONMENTAL & OCCUPATIONAL HEALTH",
                      "GENERAL & INTERNAL MEDICINE",
                      "RADIOLOGY, NUCLEAR MEDICINE & MEDICAL IMAGING")
other <- c("SCIENCE & TECHNOLOGY - OTHER TOPICS",
           "OPERATIONS RESEARCH & MANAGEMENT SCIENCE", 
           "INFORMATION SCIENCE & LIBRARY SCIENCE",
           "ARTS & HUMANITIES - OTHER TOPICS",
           "EDUCATION & EDUCATIONAL RESEARCH", "MATHEMATICS", 
           "CHEMISTRY", "ELECTROCHEMISTRY")


df_format <- df_wide %>%
  select(DI, PY, AU, SC) %>%
  separate(col = SC, 
           into = c("col1", "col2", "col3", "col4", "col5"), 
           sep = ";") %>%
  pivot_longer(cols = c(col1:col5), 
               names_to = "SC_all", 
               values_to = "SC_terms") %>% 
  select(-SC_all) %>%
  filter(!is.na(SC_terms),
         !is.na(PY)) %>%
  mutate(SC_terms = trimws(SC_terms), 
         SC_group = ifelse(SC_terms %in% life_sciences, "Life Sciences", NA),
         SC_group = ifelse(SC_terms %in% physical_sciences, "Physical Sciences", SC_group),
         SC_group = ifelse(SC_terms %in% earth_environmental_sciences, "Earth & Environmental Sciences", SC_group),
         SC_group = ifelse(SC_terms %in% medical_sciences, "Medical Sciences", SC_group),
         SC_group = ifelse(SC_terms %in% engineering, "Engineering", SC_group),
         SC_group = ifelse(SC_terms %in% other, "Other", SC_group),
         SC_group = factor(SC_group, 
                           levels = c("Engineering", "Physical Sciences", "Other",
                                      "Medical Sciences",
                                      "Earth & Environmental Sciences",
                                      "Life Sciences"),
                           ordered = TRUE)) %>%
  group_by(PY, SC_group) %>%
  count() %>%
  ungroup() %>%
  group_by(PY) %>%
  mutate(prop = n / sum(n))


# Figure:

# Numeric count (upper) plot:
number_pubs_plot <- df_format %>%
  ggplot(aes(x = PY, y = n)) +
  geom_bar(aes(fill = SC_group),
           stat = "identity",
           alpha = 0.45) +
  scale_fill_viridis_d("Field of Study", option = "plasma") +
  guides(fill = guide_legend(override.aes = list(alpha = 1))) +
  new_scale_fill() +
  geom_bar(aes(fill = SC_group, color = SC_group),
           stat = "identity") +
  scale_fill_manual(values = c("transparent", "transparent",
                               "transparent", "transparent",
                               "#FCA636FF", "#F0F921FF"),
                               guide = "none") +
  scale_color_manual(values = c("transparent", "transparent",
                                "transparent", "transparent",
                                "black", "black"),
                                guide = "none") +
  ylab("Number of Abstracts") +
  xlab(NULL) +
  theme_bw() +
  theme(axis.title = element_text(size = 14),
        axis.text.x = element_text(size = 10),
        axis.text.y = element_text(size = 10),
        axis.title.y = element_text(margin = margin(0, 20, 0, 0)),
        axis.title.x = element_text(margin = margin(20, 0, 0, 0)),
        plot.margin = margin(20, 20, 20, 20),
        legend.key.height = unit(0.3, "in"),
        legend.key.width = unit(0.25, "in"),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 12))

# Check
number_pubs_plot

# Proportion (lower) plot:
proportion_pubs_plot <- df_format %>%
  ggplot(aes(x = PY, y = prop)) +
  geom_bar(aes(fill = SC_group),
           stat = "identity", position = "stack",
           alpha = 0.45) +
  scale_fill_viridis_d(option = "plasma",
                       guide = "none") +
  new_scale_fill() +
  geom_bar(aes(fill = SC_group, color = SC_group),
           stat = "identity", position = "stack") +
  scale_fill_manual(values = c("transparent", "transparent",
                               "transparent", "transparent",
                               "#FCA636FF", "#F0F921FF"),
                               guide = "none") +
  scale_color_manual(values = c("transparent", "transparent",
                                "transparent", "transparent",
                                "black", "black"),
                                guide = "none") +
  ylab("Proportion of Abstracts") +
  xlab("Publication Year") +
  theme_bw() +
  theme(axis.title = element_text(size = 14),
        axis.text.x = element_text(size = 10),
        axis.text.y = element_text(size = 10),
        axis.title.y = element_text(margin = margin(0, 20, 0, 0)),
        axis.title.x = element_text(margin = margin(20, 0, 0, 0)),
        plot.margin = margin(20, 20, 20, 20))

# Check
proportion_pubs_plot

# Combine into a single plot with two panels:
arranged_fig <- ggarrange(number_pubs_plot, proportion_pubs_plot,
                          common.legend = TRUE, nrow = 2, ncol = 1,
                          legend = "right")

# Check
arranged_fig

# Export
ggsave(filename = "../figures/number_and_prop_abs_arranged.png",
       plot = arranged_fig, device = "png", width = 10, height = 7, units = "in")
