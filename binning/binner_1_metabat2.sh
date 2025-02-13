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
mkdir binning_out/binners/metabat2

echo "Beginning to run metabat2 on $1 with a min. contig size of $6 and using the assembly file: $2. Coverage files will be taken from the $3 directory and all results will be put in the generated binning_out directory." 

## METABAT2 SECTION

jgi_summarize_bam_contig_depths --outputDepth binning_out/binners/metabat2/$1-depth.txt --pairedContigs binning_out/binners/metabat2/$1-paired.txt --referenceFasta $2 $3/*.bam && 

metabat2 --seed 0221 -v -d --numThreads $5 --minCVSum 0 --minCV 0.1 --minContig $6 -i $2 -a binning_out/binners/metabat2/$1-depth.txt -o binning_out/binners/metabat2/bins && 

rm cluster.log.* &&

echo "metabat2 section has finished"
