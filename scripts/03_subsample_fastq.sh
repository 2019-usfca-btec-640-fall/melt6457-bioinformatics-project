#!/bin/bash

# subsample to 1% of the total number of reads in the file.fastq
# this will speed up the blast searching SIGNIFICANTLY and is a key step
# needs to be turned into a for loop to work on all files
cat /data/raw-fastq-files/BMI_Plate51WellE1_16S_R1.fastq | paste - - - - | awk 'BEGIN{srand(1234)}{if(rand() < 0.005) print $0}' | tr '\t' '\n' > /data/subsampled-fastq/BMI_Plate51WellE1_16S_R1.subsampled.fastq
