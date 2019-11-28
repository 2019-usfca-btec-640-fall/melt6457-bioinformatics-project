#!/bin/bash

#######################################################################
# Summarize Blast Results using multiple analyses:
#	-Overview: get the counts for all unique blast matches
#	-TopMatch: get the top match for each file with query cover 100
#
# Author: Kory Melton
# November 17, 2019
# kmelton@dons.usfca.edu
#######################################################################

printf "Curating blast file...\n"
# Title files and ensure they are made"
blastFile="output/blast_results.csv"
curatedBlastFile="output/curatedBlastFile.csv"
curatedSummaryCsv="output/curatedSummary.csv"
curatedOverviewFile="output/curatedOverview.txt"
curatedSummaryFile="output/curatedSummary.txt"

touch "$blastFile" "$curatedBlastFile" "$curatedSummaryCsv" "$curatedOverviewFile" "$curatedSummaryFile"

# curate the file by pulling out specific terms
grep -v -e "uncultured" -e "bacterium" -e "Bacterium" -e "unidentified" -e "fungal" "$blastFile" > "$curatedBlastFile"

printf "Processing curated file...\n"
# get an overview of the species found in curated BLAST
# first line gets just the Phylum
cut -d, -f1 < "$curatedBlastFile" | cut -d" " -f1 > "$curatedOverviewFile"
# second line gets the entire species
#cut -d, -f1 <"$curatedBlastFile" > "$curatedOverviewFile"

printf "Sorting...\n"
# sort out the top 20 most prevalent files
# awk removes leading whitespace
sort < "$curatedOverviewFile" | uniq -c | sort -n | tail -20 | awk '{$1=$1;print}' > "$curatedSummaryFile"

printf "Making Csv...\n"
# replace the space with a comma (to make it a csv file) and add info to the top of the file
sed -i 's/\ /,/g' "$curatedSummaryFile"
sed '1iCount,Genus' "$curatedSummaryFile" > "$curatedSummaryCsv"

printf "Get overview file...\n"
# get an overview of the species found in BLAST
overviewFile=output/overview.txt
cut -d, -f1 < output/blast_results.csv | uniq -c | sort | head -30 > "$overviewFile"

# get the top match for each file
printf "Get top match for each file...\n"
# set the topMatchFile and create it
topMatchFile=output/topMatch.txt
rm output/topMatch.txt # remove previous iterations so you get a clean file
touch output/topMatch.txt

printf "Sort out top matches...\n"
# use a for loop to go through each file
for file in output/blast_results/*.csv
do
	grep "100.0" < "$file" | cut -d, -f1 | uniq -c | sort | awk '{$1=""; print}' | head -1 >> "$topMatchFile"
done

# get a count for how the unique top matches
printf "Get final count...\n"
uniq -c < "$topMatchFile" | sort > output/topMatch_sorted.txt
