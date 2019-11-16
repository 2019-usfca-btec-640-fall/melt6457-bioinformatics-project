#!/bin/bash

#####################################################################################
# Script to run blast against the local database to find the top match for
# each of the SUBSAMPLED fastq
#
# options and what they're for:
# 	-db sets which database to use, in this case the nucleotide database
# 	-num_threads is how many different processor threads to use
# 	-outfrmt is the output format, further info available here:
# 		https://www.ncbi.nlm.nih.gov/books/NBK279675/
# 	-out is the filename to save the results in
# 	-max_target_seqs is the number of matches ot return for each query
# 	-negative_gilist tells BLAST which sequences to exclude from matches
# 		This cuts down on the number of uncultured or environmental matches
# 	-query is the fasta file of sequences we want to search for matches to
#
# Fasta files must be in /data/trimmed-fasta for this script to work
#
# This is the sixth scripts in a pipeline to analyze illumina data from NEON
#	Site: UNDE
#
# Authors: Naupaka Zimmerman & Kory Melton
# November 16, 2019
# kmelton@dons.usfca.edu
#####################################################################################

# use a for loop to run blast on each subsampled and trimmed fasta file

for file in /data/trimmed-fasta/*.fasta
do
	# run BLAST
	blastn -db /blast-db/nt -num_threads 4 -outfmt '10 sscinames std' -out /data/blast-results/"$(basename -s .subsampled.trim.fasta "$file")".blast_result.csv -max_target_seqs 1 -negative_gilist /blast-db/2018-09-19_environmental_sequence.gi -query "$file"
done

# make an output file with all blast results concatenated
cat /data/blast-results/*.csv > output/blast_results.csv

