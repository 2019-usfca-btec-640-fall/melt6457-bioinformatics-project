# read data in from csv
blastResults <- read.csv("output/curatedSummary.csv")
# flip the order of the data so the genus comes first
blastResults <- blastResults[, c(2, 1)] %>%
  arrange(desc(Count))

# make table
kable(blastResults)