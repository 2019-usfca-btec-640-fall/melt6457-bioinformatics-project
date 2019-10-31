#!/bin/bash

# A script to move all fastq files to a folder
# named /data/raw-fastq-files
# NOTE THIS WILL DELETE THE FILES IN THAT DIRECTORY!!

# for loop to go through each folder in
# /data/unzipped-messy/hpc/home/minardsmitha/NEON

rm /data/raw-fastq-files/*.fastq

# change into the NEON directory
cd /data/unzipped-messy/hpc/home/minardsmitha/NEON

# copy for each directory with fastq files
cp 16S_Feb5-2018_BF462/RAW_FASTQ/RAW_Upload_to_BOX/*.fastq /data/raw-fastq-files
cp 16S_ITS_2017/Aug_28_run_B9994/RAW_FASTQ/16S/RAW_Upload_to_BOX/R1/*.fastq /data/raw-fastq-files
cp 16S_ITS_2017/Sept_23_Run_BF8M2/RAW_FASTQ/16S/RAW_Upload_to_BOX/R1/*.fastq /data/raw-fastq-files
cp 16S_ITS_2018/BRF6G_16S_May_20_2018/RAW_Upload_to_BOX/*.fastq /data/raw-fastq-files
cp 16S_ITS_Aug-Sept_2017/Sept_5_Run_B69RN/RAW_FASTQ/16S/RAW_Upload_to_BOX/*.fastq /data/raw-fastq-files

