#!/bin/bash

# run trimmomatic to throw out bad sequences, trim when quality gets low, or if
# sequences are too short you will need to turn this into a for loop to process
# all of your SUBSAMPLED files
TrimmomaticSE -threads 4 -phred33 /data/subsampled-fastq/BMI_Plate51WellE1_16S_R1.subsampled.fastq /data/trimmed-fastq/$(basename -s .fastq /data/subsampled-fastq/BMI_Plate51WellE1_16S_R1.subsampled.fastq).trim.fastq LEADING:5 TRAILING:5 SLIDINGWINDOW:8:25 MINLEN:200
