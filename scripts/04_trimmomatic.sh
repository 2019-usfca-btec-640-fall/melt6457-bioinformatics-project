# run trimmomatic to throw out bad sequences, trim when quality gets low, or if
# sequences are too short you will need to turn this into a for loop to process
# all of your SUBSAMPLED files
TrimmomaticSE -threads 4 -phred33 data/raw_data/YOURFILENAME.fastq data/trimmed/$(basename -s .fastq YOURFILENAME.fastq).trim.fastq LEADING:5 TRAILING:5 SLIDINGWINDOW:8:25 MINLEN:200
