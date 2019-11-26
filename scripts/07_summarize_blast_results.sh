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

# pull out uncultued bacterium
blastFile="output/blast_results.csv"
curatedBlastFile="output/curatedBlastFile.csv"
grep -v -e "uncultured" -e "bacterium" -e "Bacterium" -e "unidentified" -e "fungal" "$blastFile" > "$curatedBlastFile"

# get an overview of the species found in curated BLAST
curatedOverviewFile="output/curatedOverview.csv"
cut -d, -f1 < "$curatedBlastFile" | cut -d" " -f1 > "$curatedOverviewFile"
#cut -d, -f1 < "$curatedBlastFile" | uniq -c | sort | head -30 > "$curatedOverviewFile"

# get an overview of the species found in BLAST
overviewFile=output/overview.txt
cut -d, -f1 < output/blast_results.csv | uniq -c | sort | head -30 > "$overviewFile"

# get the top match for each file

# set the topMatchFile and create it
topMatchFile=output/topMatch.txt
rm output/topMatch.txt # remove previous iterations so you get a clean file
touch output/topMatch.txt

# use a for loop to go through each file
for file in output/blast_results/*.csv
do
	grep "100.0" < "$file" | cut -d, -f1 | uniq -c | sort | awk '{$1=""; print}' | head -1 >> "$topMatchFile"
done

# get a count for how the unique top matches

uniq -c < "$topMatchFile" | sort > output/topMatch_sorted.txt
