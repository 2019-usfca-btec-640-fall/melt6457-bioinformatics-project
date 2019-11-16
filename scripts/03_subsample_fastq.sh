#!/bin/bash

##########################################################################################
# Script to subsample .5% of the total number of reads in each fastq file
# 	this will speed up the blast searching SIGNIFICANTLY and is a key step
#
# Fastq files must be in raw-fastq-files for this script to work
#
# This is the third script in a pipeline to analyze illumina data from NEON
#	Site: UNDE
#
# Authors: Naupaka Zimmerman & Kory Melton
# November 16th, 2019
# kmelton@dons.usfca.edu
##########################################################################################

for file in /data/raw-fastq-files/*.fastq
do
	# use echo to print out progress of script

	echo "$file"

	# save outputfile to make shellcheck happy

	outputfile=/data/subsampled-fastq/"$(basename -s .fastq "$file")".subsampled.fastq

	# randomly subsampled .5% of the fastq files and print the results to outputfile

	paste - - - - < "$file" | awk 'BEGIN{srand(1234)}{if(rand() < 0.005) print $0}' | tr '\t' '\n' > "$outputfile"
done
