#!/bin/bash

###this is to be run once you have your chosen assembly and the mapping files all done 
##requirements, concoct, maxbin2, metabat2, and parallel

#I specify seed 0221 for myself. If you want a different seed or a random seed you need to manually go through and change this. 

#1 is your sample

#2 arg is your assembly 

#3 arg is your path to the specified mapping files - these need to be all in their own directory  - DO NOT END this path in a slash, these should be sorted bams and their respecitve indexes, sorted bam endsing should be *-sorted.bam

#4 arg is your max threadcount 

#5 arg is your min contig length to be considered for binning

## first test if the output directory already exists and if not --> make it 

test -d binning_out || mkdir -p binning_out
test -d binning_out/binners || mkdir -p binning_out/binners
mkdir binning_out/binners/concoct

echo "Beginning to run concoct on $1 with a min. contig size of $6 and using the assembly file: $2. Coverage files will be taken from the $3 directory and all results will be put in the generated binning_out directory." 

## CONCOCT SECTION

mkdir binning_out/binners/concoct/tmp_concoct_files
mkdir binning_out/binners/concoct/bin_tmp
mkdir binning_out/binners/concoct/BINS

cut_up_fasta.py $2 -c 10000 -o 0 --merge_last -b binning_out/binners/concoct/tmp_concoct_files/$1-10K.bed > binning_out/binners/concoct/tmp_concoct_files/$1-10K.fna &&


concoct_coverage_table.py binning_out/binners/concoct/tmp_concoct_files/$1-10K.bed $3/*.bam >> binning_out/binners/concoct/tmp_concoct_files/coverage_table.tsv &&
  

concoct --threads $5 --length_threshold $6 --composition_file binning_out/binners/concoct/tmp_concoct_files/$1-10K.fna --coverage_file binning_out/binners/concoct/tmp_concoct_files/coverage_table.tsv -b binning_out/binners/concoct/bin_tmp/ &&


merge_cutup_clustering.py binning_out/binners/concoct/bin_tmp/clustering_gt$6.csv >> binning_out/binners/concoct/bin_tmp/clustering_merged.csv &&


extract_fasta_bins.py $2 binning_out/binners/concoct/bin_tmp/clustering_merged.csv --output_path binning_out/binners/concoct/BINS &&

echo "concoct section has finished!"
