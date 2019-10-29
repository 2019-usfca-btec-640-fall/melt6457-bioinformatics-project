#!/bin/bash

# A script to unzip a series of tar.gz fastq
# files and then run fastqc on all of them
# in order to check the sequence quality of 
# the forward (R1) reads

# Kory Melton
# October 28, 2019
# kmelton@dons.usfca.edu

# unzip all of the R1 tar.gz files using
# a for loop

for file in /data/*R1*.tar.gz
do
       tar -xvf $file -C /data/unzipped
done
