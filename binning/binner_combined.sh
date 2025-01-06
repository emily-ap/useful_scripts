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
mkdir $4/binners/metabat2
mkdir $4/binners/maxbin2
mkdir $4/binners/concoct

## METABAT2 SECTION

jgi_summarize_bam_contig_depth --outputDepth $4/binners/metabat2/$1-depth.txt --pairedContigs $4/binners/metabat2/$1-paired.txt --referenceFasta $2 $3/*.bam && 

metabat2 --seed 0221 -v -d --numThreads $5 --minCVSum 0 --minCV 0.1 --minContig $6 -i $2 -a $4/binners/metabat2/$1-depth.txt -o $4/binners/metabat2/bins && 

echo "metabat2 section has finished"

## MAXBIN2 SECTION

# maxbin2 step 0 --> prepare the directories 

mkdir $4/binners/maxbin2/abundance
mkdir $4/binners/maxbin2/bins
mkdir $4/binners/maxbin2/bins/maxbin2_markerset40_bin

# maxbin2 step 1 --> makes the abundance files from the metabat2 depth file

maxbin_workdir=$4/binners/maxbin2
depthfile=$4/binners/metabat2/$1-depth.txt 
depthfile_ncol=$(awk -F'\t' '{print NF; exit}' ${depthfile}) 

seq 4 2 ${depthfile_ncol} | parallel --jobs $5 cut -f1,{} -d"$'\t'" $depthfile '|' tail -n +2 '>' ${maxbin_workdir}/abundance/abundance_file_{} && 

# maxbin2 step 2 --> uses the newly created abundance files to bin everything

# Create a file with a list of abundance file paths (the -abund_list used in the run_MaxBin.pl command)

find ${maxbin_workdir} -type f -name "abundance_file_*" > ${maxbin_workdir}/abundance/abund_list &&

# Run Maxbin2 with bacteria and archaea marker set (40 marker genes)

run_MaxBin.pl -contig $2 -out ${maxbin_workdir}/bins/maxbin2_markerset40_bin -abund_list ${maxbin_workdir}/abundance/abund_list -min_contig_length $6 -thread $5 -prob_threshold 0.9 -markerset 40 && 

echo "maxbin2 section has finished" &&

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






















