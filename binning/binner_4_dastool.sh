#!/bin/bash

### this is to be run once you have your chosen assembly and the mapping files all done 
## requirements, dastool version, R (>v4, =v3 is good), pullseq, diamond
# input directory needs to be 

#I specify seed 0221 for myself. If you want a different seed or a random seed you need to manually go through and change this. 

#1 is your sample

#2 arg is your assembly 

#3 arg is your path to the specified mapping files - these need to be all in their own directory  - DO NOT END this path in a slash, these should be sorted bams and their respecitve indexes, sorted bam endsing should be *-sorted.bam

#4 arg is your output directory for the binning of that sample, do not put a slash at the end of this

#5 arg is your max threadcount 

#$6 arg is your min contig length to be considered for binning

## first test if the output directory already exists and if not --> make it 

test -d binning_out || mkdir -p binning_out
test -d binning_out/dastool_prepfiles || mkdir -p binning_out/dastool_prepfiles
mkdir binning_out/

echo "Beginning to run concoct on $1 with a min. contig size of $6 and using the assembly file: $2. Coverage files will be taken from the $3 directory and all results will be put in the generated binning_out directory." 

## establish where the binners output bins are 

mkdir binning_out/binners/concoct/tmp_concoct_files
mkdir binning_out/binners/concoct/bin_tmp
mkdir binning_out/binners/concoct/BINS


