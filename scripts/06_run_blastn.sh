# run blast against the local database to find the top match for each of the
# sequences in your SUBSAMPLED fastq files
# options and what they're for:
# -db sets which database to use, in this case the nucleotide database
# -num_threads is how many different processor threads to use
# -outfrmt is the output format, further info available here:
# https://www.ncbi.nlm.nih.gov/books/NBK279675/
# -out is the filename to save the results in
# -max_target_seqs is the number of matches ot return for each query
# -negative_gilist tells BLAST which sequences to exclude from matches
# This cuts down on the number of uncultured or environmental matches
# -query is the fasta file of sequences we want to search for matches to
blastn -db /blast-db/nt -num_threads 4 -outfmt '10 sscinames std' -out blast_results.csv -max_target_seqs 1 -negative_gilist /blast-db/2018-09-19_environmental_sequence.gi -query query_seqs.fasta
