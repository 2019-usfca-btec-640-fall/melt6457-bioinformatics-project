#!/bin/bash

# subsample to 1% of the total number of reads in the file.fastq
# this will speed up the blast searching SIGNIFICANTLY and is a key step
# needs to be turned into a for loop to work on all files

for file in /data/raw-fastq-files/*.fastq
do
	# use echo to print out progress of script
	echo $file

	# randomly subsampled .5% of the fastq files
	paste - - - - < "$file" | awk 'BEGIN{srand(1234)}{if(rand() < 0.005) print $0}' | tr '\t' '\n' > /data/subsampled-fastq/"$(basename -s .fastq "$file")".subsampled.fastq
done
