#!/bin/bash

cd /data/raw-fastq-files

for file in /data/raw-fastq-files/*.fastq
do
	grep -c "^+$" ./*.fastq
done

echo "\nNumber of fastq files: "
	ls ./*.fastq | wc -l
echo "\n"

cd /data/subsampled-fastq

echo "\n Samples per File"
for file in /data/subsampled-fastq/*.fastq
do
	grep -c "^+$" $file
done

echo "\nNumer of subsampled files: "
ls *.fastq | wc -l
echo "\n"
