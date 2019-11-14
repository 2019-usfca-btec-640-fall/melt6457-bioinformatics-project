#!/bin/bash

# convert to fasta for BLAST
# you need to modify this to save the converted fasta file to a file
# instead of printing to the screen
# you'll need to turn this into a for loop too

for file in /data/trimmed-fastq/*.fastq
do
	echo "$file"
	bioawk -c fastx '{print ">"$name"\n"$seq}' "$file" > /data/trimmed-fasta/"$(basename -s .fastq "$file")".fasta
done
