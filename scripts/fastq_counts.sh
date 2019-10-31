#!/bin/bash

cd /data/raw-fastq-files

for file in /data/raw-fastq-files/*.fastq
do
	grep -c "^+$" *.fastq
done

echo "\nNumber of fastq files: "
ls *.fastq | wc -l
echo "\n"
