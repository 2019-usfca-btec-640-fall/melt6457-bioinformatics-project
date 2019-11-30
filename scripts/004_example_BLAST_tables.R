# read data in from csv
blast_results <- read.csv("output/curatedSummary.csv")
# flip the order of the data so the genus comes first
blast_results <- blast_results[, c(2, 1)] %>%
  arrange(desc(Count))

# make table
kable(blast_results)