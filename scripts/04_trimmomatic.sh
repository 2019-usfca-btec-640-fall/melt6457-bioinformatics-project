#!/bin/bash

# run trimmomatic to throw out bad sequences, trim when quality gets low, or if
# sequences are too short you will need to turn this into a for loop to process
# all of your SUBSAMPLED files

for file in /data/subsampled-fastq/*.fastq
do
	# use echo to test file
	# echo $file
	TrimmomaticSE -threads 4 -phred33 $file /data/trimmed-fastq/$(basename -s .fastq $file).trim.fastq LEADING:5 TRAILING:5 SLIDINGWINDOW:8:25 MINLEN:200
done
