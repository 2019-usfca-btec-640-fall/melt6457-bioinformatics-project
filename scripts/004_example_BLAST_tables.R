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

# read curated summary data in from csv
blast_results <- read.csv("output/curatedSummary.csv")
# flip the order of the data so the genus comes first
top_10_genus <- blast_results[, c(2, 1)] %>%
  arrange(desc(Count)) %>%
  head(10)

# make table
kable(top_10_genus)

# read curated data on top 5 in from csv
top_5_genus <- read.csv("output/top5blast.csv")

# mutate the data frame to split scientific name into genus and species
top_5_genus$Genus <- gsub(" .*$", "", top_5_genus$Scientific.Name)
top_5_genus$Species <- gsub(".* ", "", top_5_genus$Scientific.Name)

# get top by species w/o Bradyrhizobium and Pseudomonas
top_3_staph_rals_pro <- top_5_genus %>%
  filter (Genus != "Bradyrhizobium") %>%
  filter (Genus != "Pseudomonas") %>%
  group_by(Genus, Species) %>%
  tally() %>%
  arrange(desc(n)) %>%
  head(3)
  
# get top 3 of Bradyrhizobium and Pseudomonas
# Bradyrhizobium
top_3_br <- top_5_genus %>%
  filter(Genus == "Bradyrhizobium") %>%
  group_by(Genus, Species) %>%
  tally() %>%
  arrange(desc(n)) %>%
  head(3)

# Pseudomonas
top_3_pseu <- top_5_genus %>%
  filter(Genus == "Pseudomonas") %>%
  group_by(Genus, Species) %>%
  tally() %>%
  arrange(desc(n)) %>%
  head(3)

# bind Bradyrhizobium and Pseudomonas
top_3_bp <- rbind(top_3_br,
                  top_3_pseu)

# graph counts with genus on x and fill species
# Filtered for only the top 10 samples
# Ralstonia was ommitted to make graph more readable
# Proteobacteria didn't have any species
top_3_bp %>%
  filter(Genus == 0 | 1) %>%
  filter(n > 10) %>%
  ggplot(aes(x = Genus,
             y = n,
             fill = Species)) +
  xlab("Genus") +
  ylab("Number of Samples") +
  ggtitle("BLAST Samples by Genus and Species") +
  geom_col(position = position_dodge()) +
  theme(axis.text.x = element_text(angle = 60,
                                   hjust = 1))

# make a table for other relevant counts
kable(top_3_staph_rals_pro)

#################################################
# Boxplots by scientific group
#################################################
# graph boxplot of percent identity by top 5 Genus
top_5_genus %>%
  ggplot(aes(x = Genus,
             y = pident)) +
  geom_boxplot() +
  ggtitle("Percent Identity by Genus") +
  xlab("Genus") +
  ylab("Percent Identity") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 60,
                                   hjust = 1)) +
  geom_hline(yintercept = 90, color = "red")

# graph boxplot of length by top 5 Genus
top_5_genus %>%
  ggplot(aes(x = Genus,
             y = length)) +
  geom_boxplot() +
  ggtitle("Length of Sequence Match by Genus") +
  xlab("Genus") +
  ylab("Length of Sequence") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 60,
                                   hjust = 1)) +
  geom_hline(yintercept = 200, color = "red")

# graph boxplot of evalue by top 5 genus
top_5_genus %>%
  filter(evalue < 1) %>%
  ggplot(aes(x = Genus,
             y = evalue)) +
  geom_boxplot() +
  ggtitle("Expected Value by Genus") +
  xlab("Genus") +
  ylab("Expected Value") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 60,
                                   hjust = 1)) +
  geom_hline(yintercept = 0.05, color = "red")

# graph boxplot of bitscore by top 5 genus
top_5_genus %>%
  ggplot(aes(x = Genus,
             y = bitscore)) +
  geom_boxplot() +
  ggtitle("Bitscore by Genus") +
  xlab("Genus") +
  ylab("Bitscore") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 60,
                                   hjust = 1)) +
  geom_hline(yintercept = 200, color = "red")

# Number of Samples in top 5 genus when controlled for
# - bitscore above 200
# - e value below 0.05
# - length above 200
# - percent identity above 90%
curated_top_5_totals <- top_5_genus %>%
  filter(bitscore > 200) %>%
  filter(evalue < 0.05) %>%
  filter(length > 200) %>%
  filter(pident > 90) %>%
  group_by(Genus) %>%
  tally()

curated_top_5_totals %>%
  ggplot(aes(x = Genus,
             y = n)) +
  geom_col() +
  ggtitle("Number of Curated Samples") +
  xlab("Genus") +
  ylab("Total Samples") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 60,
                                   hjust = 1))

top_5_totals <- top_10_genus %>%
  head(5) %>%
  arrange(Genus)

sort(top_5_totals$Genus)

top_5_totals$curated.count <- curated_top_5_totals$n

top_5_totals <- top_5_totals %>%
  arrange(desc(Count))

kable(top_5_totals)
