#!/bin/bash

##################################################
# Script to get counts for files throughout
# the analysis pipeline
#
# This must be run at the main directory
# for the project!!!
#
# Kory Melton
# November 16, 2019
# kmelton@dons.usfca.edu
##################################################

############# RAW FASTQ FILES ####################
cd /data/raw-fastq-files

# Samples per file commented out to supress output
#for file in /data/raw-fastq-files/*.fastq
#do
#	grep -c "^+$" ./*.fastq
#done

printf "\nNumber of fastq files: "
find ./*.fastq | wc -l
printf "\n"


############ SUBSAMPLED FASTQ FILES ##############
cd /data/subsampled-fastq

# Samples per file commented out to supress output
#echo "\n Samples per File"
#for file in /data/subsampled-fastq/*.fastq
#do
#	grep -c "^+$" $file
#done

printf "\nNumer of subsampled files: "
find ./*.fastq | wc -l
printf "\n"

############# TRIMMED FASTQ FILES ################
printf "\n Number of Trimmed fastq files: "
find /data/trimmed-fastq/*.fastq | wc -l
printf "\n"

############# TRIMMED FASTA FILES ################
printf "\n Number of Trimmed fasta files: "
find /data/trimmed-fasta/*.fasta | wc -l
printf "\n"

################ BLAST FILES #####################
printf "\n Number of Blast files: "
find output/blast_results/*.csv | wc -l
printf "\n"
