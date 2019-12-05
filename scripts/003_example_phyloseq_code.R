# The following is some example code that you can use for a starting
# point in your own analyses within the chunks of your rmarkdown
# report

# Be sure to install these packages before running this script
# They can be installed either with the intall.packages() function
# or with the 'Packages' pane in RStudio

# load general-use packages
library("dplyr")
library("tidyr")
library("knitr")
library("ggplot2")
library("lubridate")
library("forcats")
library("ggthemes")

# These are the primary packages well use to clean and analyze the data
# this package needs to be installed from bioconductor -- it's not on CRAN
# see info here: https://benjjneb.github.io/dada2/dada-installation.html
library("dada2")

# And this to visualize our results
# it also needs to be installed from bioconductor
library("phyloseq")

# load in the saved phyloseq object to work with
load("output/phyloseq_obj.Rda") # need in RMarkdown file

##########################################
# Make plot ID's more readable
##########################################

phyloseq_obj@sam_data[["plotID"]] <-
  substring(phyloseq_obj@sam_data[["plotID"]],
            6,
            8)

##########################################
# Make melted phyloseq object
##########################################

# melt phyloseq obj into a data frame for dplyr/ggplot
# analysis and visualization
melted_phyloseq <- psmelt(phyloseq_obj)

# turn all factor columns into character columns for dplyr
melted_phyloseq <- melted_phyloseq %>%
  mutate_if(is.factor, as.character)

##########################################
# Number of Samples
##########################################

# Get number of samples by year, plot, month
sample_info <- melted_phyloseq %>%
  distinct(OTU, .keep_all = TRUE) %>%
  group_by(plotID, collect_year, collect_month) %>%
  tally()

# Graph the number of samples by month, with fill year
sample_info %>%
  ggplot(aes(x = factor(collect_month),
             y = n,
             fill = factor(collect_year))) +
  xlab("Collection Month") +
  ylab("Number of Samples") +
  geom_col(position = position_dodge())

# Graph the number of samples by month, with fill year
# for plot 6
sample_info %>%
  filter(plotID == "006") %>%
  ggplot(aes(x = factor(collect_month),
             y = n,
             fill = factor(collect_year))) +
  xlab("Collection Month") +
  ylab("Number of Samples") +
  geom_col(position = position_dodge())

# Graph the plots in month 5 and 8
sample_info %>%
  filter(collect_month == 5 | collect_month == 8) %>%
  group_by(plotID, collect_year) %>%

  ggplot(aes(x = plotID,
             y = n,
             fill = factor(collect_year))) +
  xlab("Plot ID") +
  ylab("Number of Samples") +
  ggtitle("Samples by plot") +
  geom_col() +
  theme(axis.text.x = element_text(angle = 60,
                                   hjust = 1)) +
  theme(legend.position = "top") +
  labs(fill = "Collection Year")

# graph the plots by month
sample_info %>%
  group_by(plotID, collect_year) %>%
  ggplot(aes(x = plotID,
             y = n,
             fill = factor(collect_month))) +
  xlab("Plot ID") +
  ylab("Number of Samples") +
  ggtitle("Samples by plot") +
  geom_col() +
  theme(axis.text.x = element_text(angle = 60,
                                   hjust = 1)) +
  theme(legend.position = "top") +
  labs(fill = "Collection Month")

# Graph the plots in month 5 and 8
sample_info %>%
  group_by(plotID, collect_month) %>%
  ggplot(aes(x = plotID,
             y = n,
             fill = factor(collect_month))) +
  xlab("Plot ID") +
  ylab("Number of Samples") +
  ggtitle("Samples by plot") +
  geom_col() +
  theme(axis.text.x = element_text(angle = 60,
                                   hjust = 1))

# counts of the top 3 phyla overall, for each of the plots
top_3_diverse_phyla <- melted_phyloseq %>%
  filter(Abundance > 0, !is.na(Phylum)) %>%
  distinct(OTU, .keep_all = TRUE) %>%
  group_by(Phylum) %>%
  tally() %>%
  arrange(desc(n)) %>%
  head(3) %>%
  pull(Phylum)

# Phyla by year
# control for
# - month 5 or month 8
# - plots: 001, 006, 008, 037, 038, 043, 044
# look at different phylum abundances

# list of plots to keep
plots <- c("001", "006", "008", "037", "038", "043", "044")
melted_phyloseq %>%
  filter(collect_month == 5 | collect_month == 8) %>%
  filter(plotID %in% plots) %>%
  group_by(collect_year, Phylum) %>%
  summarize(sum_abund = sum(Abundance,
                            na.rm = TRUE)) %>%
  filter(Phylum %in% top_3_diverse_phyla) %>%
  ggplot(aes(x = factor(collect_year),
             y = sum_abund,
             fill = Phylum)) +
  xlab("Collection Year") +
  ylab("Abundance") +
  geom_col(position = position_dodge())

# phyla by month and year
diverse_phyla <- melted_phyloseq %>%
  filter(Abundance > 0, !is.na(Phylum)) %>%
  distinct(OTU, .keep_all = TRUE) %>%
  group_by(Phylum) %>%
  tally() %>%
  arrange(desc(n)) %>%
  head(5) %>%
  pull(Phylum)

melted_phyloseq %>%
  group_by(collect_month, collect_year, Phylum) %>%
  summarize(sum_abund = sum(Abundance,
                            na.rm = TRUE)) %>%
  filter(Phylum %in% diverse_phyla) %>%
  ggplot(aes(x = Phylum,
             y = sum_abund,
             fill = Phylum)) +
  xlab("") +
  ylab("Abundance") +
  geom_col(position = position_dodge()) +
  facet_grid(collect_year ~ collect_month) +
  theme(axis.text.x = element_blank()) +
  ggtitle("Abundance of Phyla by Month and Year")

diverse_proteobacteria <- melted_phyloseq %>%
  filter(collect_year == 2016) %>%
  filter(Abundance > 0, !is.na(Genus)) %>%
  distinct(OTU, .keep_all = TRUE) %>%
  group_by(Genus) %>%
  tally() %>%
  arrange(desc(n)) %>%
  head(6) %>%
  pull(Genus)

melted_phyloseq %>%
  filter(collect_month != 10) %>%
  group_by(collect_month, Genus, Phylum) %>%
  summarize(sum_abund = sum(Abundance,
                            na.rm = TRUE)) %>%
  filter(Genus %in% diverse_proteobacteria) %>%
  ggplot(aes(x = Genus,
             y = sum_abund,
             fill = Genus)) +
  xlab("") +
  ylab("Abundance") +
  geom_col(position = position_dodge()) +
  facet_grid(Phylum ~ collect_month) +
  theme(axis.text.x = element_blank()) +
  ggtitle("Abundance of Genus in Proteobacteria by Month")

##########################################
# Phyloseq-native analyses
##########################################

# alpha diversity metrics -- see many more
# examples here, under 'Tutorials': https://joey711.github.io/phyloseq

# get richness object for more flexible graphing
diversity <- estimate_richness(phyloseq_obj,
                               split = FALSE,
                               measures = "Shannon")

# prune for 3 different datasets
# in months 5 and 8
# -2016
# -2017

phyloseq_5_8 <- prune_samples(phyloseq_obj@sam_data$collect_month == 5
                              | phyloseq_obj@sam_data$collect_month == 8,
                              phyloseq_obj)
phyloseq_2016 <- prune_samples(phyloseq_obj@sam_data$collect_year == 2016,
                               phyloseq_obj)
phyloseq_2017 <- prune_samples(phyloseq_obj@sam_data$collect_year == 2017,
                               phyloseq_obj)
phyloseq_5 <- prune_samples(phyloseq_obj@sam_data$collect_month == 5,
                            phyloseq_obj)

# richness in 2016
plot_richness(phyloseq_2016,
              x = "plotID",
              measures = "Shannon") +
  xlab("Plot ID") +
    geom_point(size = 2,
               aes(color = factor(collect_month)))

# richness in months 5 and 8 with year as the color
plot_richness(phyloseq_5_8,
              x = "plotID",
              measures = "Shannon") +
  xlab("Plot ID") +
  geom_point(aes(color = factor(collect_year)))

# richness in May
plot_richness(phyloseq_5,
              x = "plotID",
              measures = "Shannon") +
  xlab("Plot ID") +
  geom_point(aes(color = factor(collect_year)))

# first step, figure out top 3 phyla overall based on
# number of sequences
top_4_phyla_may <- melted_phyloseq %>%
  group_by(Phylum) %>%
    filter(collect_month == 5) %>%
    summarize(sum_abund = sum(Abundance,
                              na.rm = TRUE)) %>%
        arrange(desc(sum_abund)) %>%
          head(4) %>%
            pull(Phylum)

top_4_phyla_jul <- melted_phyloseq %>%
  group_by(Phylum) %>%
  filter(collect_month == 7) %>%
  summarize(sum_abund = sum(Abundance,
                            na.rm = TRUE)) %>%
  arrange(desc(sum_abund)) %>%
  head(4) %>%
  pull(Phylum)

melted_phyloseq %>%
  group_by(collect_month, Phylum) %>%
  summarize(sum_abund = sum(Abundance,
                            na.rm = TRUE)) %>%
    #filter(Phylum %in% top_4_phyla) %>%
    ggplot(aes(x = factor(collect_month),
               y = sum_abund,
               fill = Phylum)) +
        xlab("Collection Month") +
          ylab("Abundance") +
            geom_col(position = position_dodge())

# test two axes plot
melted_phyloseq %>%
  filter(collect_year == 2016)
  group_by(plotID) %>%
  summarize(sum_abund = sum(Abundance,
                            na.rm = TRUE)) %>%
  #filter(Phylum %in% top_4_phyla) %>%
  ggplot(aes(x = factor(collect_month),
             y = sum_abund,
             fill = Phylum)) +
  xlab("Collection Month") +
  ylab("Abundance") +
  geom_col(position = position_dodge())

#################################################
# Table of top 20 genus
#################################################

# get top 20 genus
top_10_genus <- melted_phyloseq %>%
  group_by(Genus) %>%
    filter(!is.na(Genus)) %>%
      summarize(sum_abund = sum(Abundance,
                                na.rm = TRUE)) %>%
        arrange(desc(sum_abund)) %>%
          head(10)

colnames(top_10_genus) <- c("Genus",
                          "Abundance")
kable(top_10_genus)

#################################################
# In-class examples 27Nov19
#################################################

melted_phyloseq %>%
  filter(Phylum %in% top_3_diverse_phyla) %>%
    group_by(collect_year, collect_month, plotID, Phylum) %>%
      summarize(sum_abundance = sum(Abundance,
                                    na.rm = TRUE)) %>%
        ggplot(aes(x = factor(collect_year),
                   y = sum_abundance,
                   color = Phylum)) +
          geom_boxplot() +
            ggtitle("Awesome boxplot") +
            xlab("Year of Sample Collection") +
            ylab("Sum of sequence abundances") +
            theme_classic() +
            scale_color_brewer(palette = "Set1")

top_10_diverse_phyla <- melted_phyloseq %>%
  filter(Abundance > 0, !is.na(Phylum)) %>%
  distinct(OTU, .keep_all = TRUE) %>%
  group_by(Phylum) %>%
  tally() %>%
  arrange(desc(n)) %>%
  head(10) %>%
  pull(Phylum)

melted_phyloseq %>%
  filter(!is.na(Phylum)) %>%
    group_by(Phylum) %>%
      summarise(sum_abund = sum(Abundance,
                                na.rm = TRUE)) %>%
        arrange(desc(sum_abund)) %>%
          mutate(Phylum = fct_inorder(Phylum)) %>%
          filter(sum_abund > 1) %>%
          mutate(is_chloro = ifelse(Phylum == "Chloroflexi",
                                    TRUE, FALSE)) %>%
            ggplot(aes(x = Phylum,
                       y = sum_abund,
                       fill = is_chloro)) +
              geom_col() +
              scale_y_log10() +
              theme_classic() +
              scale_fill_manual(name = NULL,
                                values = c("grey", "green")) +
              theme(axis.text.x = element_text(angle = 60,
                                               hjust = 1)) +
              theme(legend.position = "none")

# table
melted_phyloseq %>%
  filter(!is.na(Kingdom)) %>%
  group_by(Kingdom) %>%
    tally() %>%
      kable(col.names = c("Kingdom", "Number of Sequences"))

# test plot of archaea and bacteria
kingdom_info <- melted_phyloseq %>%
  filter(!is.na(Kingdom)) %>%
  distinct(OTU, .keep_all = TRUE) %>%
  group_by(Kingdom, collect_year, collect_month) %>%
  tally()

  summarise(sum_abund = sum(Abundance,
                            na.rm = TRUE))

kingdom_info %>%
  ggplot(aes(x = factor(collect_year),
             y = n,
             fill = Kingdom)) +
  geom_col()

kingdom_table <- matrix(c(kingdom_info$n[1],
                        kingdom_info$n[5],
                        0,
                        kingdom_info$n[6],
                        kingdom_info$n[2],
                        kingdom_info$n[7],
                        0,
                        0,
                        kingdom_info$n[3],
                        kingdom_info$n[8],
                        0,
                        0,
                        kingdom_info$n[4],
                        kingdom_info$n[9],
                        0,
                        kingdom_info$n[10]),
                      ncol = 8)

colnames(kingdom_table) <- c("May", "July", "August", "October",
                             "May", "July", "August", "October")
rownames(kingdom_table) <- c("Archaea", "Bacteria")

kable(kingdom_table)
  # kable_styling(c("striped", "bordered")) %>%
  # add_header_above(c(" ",
  #                    "2016" = 4,
  #                    "2017" = 4))

# list the top phyla in descending order
phyla_by_plot <- melted_phyloseq %>%
  group_by(plotID, Phylum) %>%
  filter(!is.na(Phylum)) %>%
  summarize(sum_abund = sum(Abundance,
                            na.rm = TRUE)) %>%
  filter(sum_abund > 0) %>%
  arrange(desc(sum_abund))

# keep only the top phyla
top_phyla_by_plot <- phyla_by_plot[!duplicated(phyla_by_plot$plotID), ]

top_phyla_by_plot %>%
  ggplot(aes(x = plotID,
             y = sum_abund,
             fill = Phylum)) +
  geom_col() +
  theme(axis.text.x = element_text(angle = 10)) +
  theme(legend.position = "top")

##################################################
# Output Unique OTUs
##################################################
melted_phyloseq %>%
  group_by(OTU) %>%
  summarize(sum_abund = sum(Abundance,
                            na.rm = TRUE)) %>%
  arrange(desc(sum_abund)) %>%
  mutate(Phylum = paste0("*", Phylum, "*")) %>%
  head(5) %>%
  pull(OTU)

##################################################
# Look at plots based on type
# deciduous forest (df): 001, 006, 007
#                        013, 014, 043
#                        019, 027
# mixed forest (mf):     008, 017, 034,
#                        035, 037, 044
# woody wetlands (ww):   002, 003, 010
#                        038
##################################################
melted_phyloseq$plot_type <- switch(melted_phyloseq$plotID,
                                "001" = "df",
                                "006" = "df",
                                "007" = "df",
                                "013" = "df",
                                "014" = "df",
                                "043" = "df",
                                "019" = "df",
                                "027" = "df",
                                "008" = "mf",
                                "017" = "mf",
                                "034" = "mf",
                                "035" = "mf",
                                "037" = "mf",
                                "044" = "mf",
                                "002" = "ww",
                                "003" = "ww",
                                "010" = "ww",
                                "038" = "ww")
