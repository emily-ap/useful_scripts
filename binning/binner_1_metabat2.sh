
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

## METABAT2 SECTION

jgi_summarize_bam_contig_depth --outputDepth $4/binners/metabat2/$1-depth.txt --pairedContigs $4/binners/metabat2/$1-paired.txt --referenceFasta $2 $3/*.bam && 

metabat2 --seed 0221 -v -d --numThreads $5 --minCVSum 0 --minCV 0.1 --minContig $6 -i $2 -a $4/binners/metabat2/$1-depth.txt -o $4/binners/metabat2/bins && 

echo "metabat2 section has finished"
