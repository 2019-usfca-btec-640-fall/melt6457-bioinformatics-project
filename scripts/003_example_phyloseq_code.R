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
# Add some data to phyloseq
##########################################

# pull out numbers from plots
# plotNum <- substring(phyloseq_obj@sam_data[["plotID"]], 6, 8)
phyloseq_obj@sam_data[["plotID"]] <- substring(phyloseq_obj@sam_data[["plotID"]], 6, 8)


# Make supplemented phyloseq by merging objects
phyloseq_supp <- merge_phyloseq(phyloseq_obj, plotNum)
head(phyloseq_supp@sam_data$plotID)

##########################################
# Phyloseq-native analyses
##########################################

# alpha diversity metrics -- see many more
# examples here, under 'Tutorials': https://joey711.github.io/phyloseq
plot_richness(phyloseq_2016,
              x = "plotID",
              measures = c("Shannon")) +
  xlab("Sample origin") +
  geom_jitter(width = 0.2) +
  theme_bw()

plot_richness(phyloseq_2017,
              x = "plotID",
              measures = c("Shannon", "Simpson")) +
  xlab("Sample origin") +
  geom_jitter(width = 0.2) +
  theme_bw()

# richness by year
plot_richness(phyloseq_obj,
              x = "plotID",
              measures = "Shannon") + 
  xlab("Plot ID") +
    geom_point(size=5, 
               alpha=0.6, 
               aes(color = factor(collect_year)))

# richness by month
plot_richness(phyloseq_obj,
              x = "plotID",
              measures = "Shannon") + 
  xlab("Plot ID") +
    geom_point(aes(color = factor(collect_month)))

# add a calculated column to the data

plot_richness(phyloseq_obj,
              x = "collect_year",
              measures = c("Shannon", "Simpson")) +
  xlab("Sample Year")
  

# bar plot of taxa by month sampled
plot_bar(phyloseq_obj,
         x = "collect_month",
         fill = "Phylum")

# bar plot of taxa by year sampled
plot_bar(phyloseq_obj,
         x = "collect_year",
         fill = "Phylum")

##########################################
# dplyr and ggplot analyses
##########################################

# melt phyloseq obj into a data frame for dplyr/ggplot
# analysis and visualization
melted_phyloseq <- psmelt(phyloseq_obj)

# turn all factor columns into character columns for dplyr
melted_phyloseq <- melted_phyloseq %>%
  mutate_if(is.factor, as.character)

summaryTable <- melted_phyloseq %>%
  filter(collect_month == 10) %>%
    group_by(Phylum) %>%
      summarize(sum_abundance = sum(Abundance,
                                    na.rm = TRUE))


##########################################
# prune to only include 2016
##########################################
phyloseq_2016 <- prune_samples(phyloseq_obj@sam_data[["collect_year"]] == 2016, phyloseq_obj)
phyloseq_2017 <- prune_samples(phyloseq_obj@sam_data[["collect_year"]] == 2017, phyloseq_obj)
phyloseq_may <- prune_samples(phyloseq_obj@sam_data[["collect_month"]] == 5, phyloseq_obj)
phyloseq_jul <- prune_samples(phyloseq_obj@sam_data[["collect_month"]] == 7, phyloseq_obj)
phyloseq_aug <- prune_samples(phyloseq_obj@sam_data[["collect_month"]] == 8, phyloseq_obj)
phyloseq_oct <- prune_samples(phyloseq_obj@sam_data[["collect_month"]] == 10, phyloseq_obj)


# abundance on y axis, year collected on x axis,
# top 3 phyla, bar graph grouped, color by phyla

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

#################################################
# Table of top 20 genus
#################################################

# get top 20 genus
top20_Genus <- melted_phyloseq %>%
  group_by(Genus) %>%
    filter(!is.na(Genus)) %>%
      summarize(sum_abund = sum(Abundance,
                                na.rm = TRUE)) %>%
        arrange(desc(sum_abund)) %>%
          head(20)

colnames(top20_Genus) <- c("Genus",
                          "Abundance")
kable (top20_Genus)

top20_Genus %>%
  ggplot(aes(x = Genus,
             y = Abundance))
    

#################################################
# In-class examples 27Nov19
#################################################

# counts of the top 3 phyla overall, for each of the plots
top_3_diverse_phyla <- melted_phyloseq %>%
  filter(Abundance > 0, !is.na(Phylum)) %>%
    distinct(OTU, .keep_all = TRUE) %>%
      group_by(Phylum) %>%
        tally() %>%
          arrange(desc(n)) %>%
            head(3) %>%
              pull(Phylum)

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
