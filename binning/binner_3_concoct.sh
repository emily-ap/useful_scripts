#!/bin/bash

###this is to be run once you have your chosen assembly and the mapping files all done 
##requirements, concoct, maxbin2, metabat2, and parallel

#I specify seed 0221 for myself. If you want a different seed or a random seed you need to manually go through and change this. 

#1 is your sample

#2 arg is your assembly 

#3 arg is your path to the specified mapping files - these need to be all in their own directory  - DO NOT END this path in a slash, these should be sorted bams and their respecitve indexes, sorted bam endsing should be *-sorted.bam

#4 arg is your output directory for the binning of that sample, do not put a slash at the end of this

#5 arg is your max threadcount 

#$6 arg is your min contig length to be considered for binning

## first test if the output directory already exists and if not --> make it 

test -d $4 || mkdir -p $4
test -d $4/binners || mkdir -p $4/binners
mkdir $4/binners/concoct

echo "Beginning to run concoct on $1 with a min. contig size of $6 and using the assembly file: $2. Coverage files will be taken from the $3 directory and all results will be put in the generated $4 directory." 

## CONCOCT SECTION

mkdir $4/binners/concoct/tmp_concoct_files
mkdir $4/binners/concoct/bin_tmp
mkdir $4/binners/concoct/BINS

cut_up_fasta.py $2 -c 10000 -o 0 --merge_last -b $4/binners/concoct/tmp_concoct_files/$1-10K.bed > $4/binners/concoct/tmp_concoct_files/$1-10K.fna &&


concoct_coverage_table.py $4/binners/concoct/tmp_concoct_files/$1-10K.bed $3/*.bam >> $4/binners/concoct/tmp_concoct_files/coverage_table.tsv &&
  

concoct --threads $5 --length_threshold $6 --composition_file $4/binners/concoct/tmp_concoct_files/$1-10K.fna --coverage_file $4/binners/concoct/tmp_concoct_files/coverage_table.tsv -b $4/binners/concoct/bin_tmp/ &&


merge_cutup_clustering.py $4/binners/concoct/bin_tmp/clustering_gt$6.csv >> $4/binners/concoct/bin_tmp/clustering_merged.csv &&


extract_fasta_bins.py $2 $4/binners/concoct/bin_tmp/clustering_merged.csv --output_path $4/binners/concoct/BINS &&

echo "concoct section has finished!"
