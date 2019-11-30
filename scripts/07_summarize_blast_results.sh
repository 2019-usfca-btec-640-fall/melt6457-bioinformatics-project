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
top5file="output/top5blast.csv"

touch "$blastFile" "$curatedBlastFile" "$curatedSummaryCsv" "$curatedOverviewFile" "$curatedSummaryFile" "$top5file"

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

# Print out a file with the top 5 matches from BLAST
# 1 - Ralstonia
# 2 - Staphylococcus
# 3 - Bradyrhizobium
# 4 - Pseudomonas
# 5 - Proteobacteria

# make a temp file
top5temp="output/top5tempFile.csv"
touch "$top5temp"

printf "Get top 5 BLAST matches...\n"
grep -e "Ralstonia" -e "Staphylococcus" -e "Bradyrhizobium" -e "Pseudomonas" -e "Proteobacteria" "$curatedBlastFile" > "$top5temp"
sed '1iScientific Name,qseqid,sseqid,pident,length,mismatch,gapopen,qstart,qend,sstart,send,evalue,bitscore' "$top5temp" > "$top5file"

# remove temp file
rm "$top5temp"
