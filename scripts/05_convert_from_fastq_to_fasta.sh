# convert to fasta for BLAST
# you need to modify this to save the converted fasta file to a file
# instead of printing to the screen
# you'll need to turn this into a for loop too
bioawk -c fastx '{print ">"$name"\n"$seq}' data/trimmed/filename.trim.fastq
