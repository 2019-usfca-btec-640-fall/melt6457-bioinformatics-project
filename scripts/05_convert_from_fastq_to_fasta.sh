#!/bin/bash

#############################################################################
# Script to convert fastq files to fasta files (needed for BLAST)
#
# Subampled and trimmed fastq files must be in /data/trimmed-fastq for this
# script to work
#
# This is the fifth script in a pipeline to analyze illumina data from NEON
#	Site: UNDE
#
# Authors: Naupaka Zimmerman & Kory Melton
# November 16th, 2019
# kmelton@dons.usfca.edu
#############################################################################

# use a for loop to convert each trimmed file

for file in /data/trimmed-fastq/*.fastq
do
	# echo the file to track progress
	echo "$file"

	# run bioawk to convert to fasta format
	outputfile=/data/trimmed-fasta/"$(basename -s .fastq "$file")".fasta
	bioawk -c fastx '{print ">"$name"\n"$seq}' "$file" > "$outputfile"
done
