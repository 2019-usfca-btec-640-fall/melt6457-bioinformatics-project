#!/bin/bash

#######################################################################
#
# use cut, sort, and uniq -c to help you summarize the results from the
# BLAST search.
#
#
#
#
#######################################################################

# get an overview of the species found in BLAST
overviewFile=output/overview.txt
cut -d, -f1 < output/blast_results.csv | uniq -c | sort | head -10 > "$overviewFile"

# get the top match for each file

# set the topMatchFile and create it
topMatchFile=output/topMatch.txt
touch output/topMatch.txt

# use a for loop to go through each file
for file in output/blast_results/*.csv
do
	cut -d, -f1 < "$file" | uniq -c | sort | cut -d' ' -f2,3 | head -1 >> "$topMatchFile"
done

# get a count for how the unique top matches

uniq -c < "$topMatchFile" | sort > output/topMatch_sorted.txt
