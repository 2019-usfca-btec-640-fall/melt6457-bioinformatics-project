#!/bin/bash

####################################################################################
# Script to run trimmomatic on subsampled files:
#	throws out bad sequences
#	trims when quality gets low or if sequences are too short
#
# Subsampled files need to be in /data/subsampled-fastq for this script to work
#
# This is the fourth script in a pipeline to analyze illumina data from NEON
#	Site: UNDE
#
# Authors: Naupaka Zimmerman & Kory Melton
# November 16th, 2019
# kmelton@dons.usfca.edu
####################################################################################

# use a for loop to step through all subsampled files

for file in /data/subsampled-fastq/*.fastq
do
	# run trimmomatic

	TrimmomaticSE -threads 4 -phred33 "$file" /data/trimmed-fastq/"$(basename -s .fastq "$file")".trim.fastq LEADING:5 TRAILING:5 SLIDINGWINDOW:8:25 MINLEN:200
done
