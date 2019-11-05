# subsample to 1% of the total number of reads in the file.fastq
# this will speed up the blast searching SIGNIFICANTLY and is a key step
# needs to be turned into a for loop to work on all files
cat file.fastq | paste - - - - | awk 'BEGIN{srand(1234)}{if(rand() < 0.01) print $0}' | tr '\t' '\n' > out.fastq
