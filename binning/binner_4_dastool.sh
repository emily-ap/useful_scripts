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

test -d $4 || mkdir -p $4
test -d $4/dastool_prepfiles || mkdir -p $4/dastool_prepfiles
mkdir $4/

echo "Beginning to run concoct on $1 with a min. contig size of $6 and using the assembly file: $2. Coverage files will be taken from the $3 directory and all results will be put in the generated $4 directory." 

## establish where the binners output bins are 

mkdir $4/binners/concoct/tmp_concoct_files
mkdir $4/binners/concoct/bin_tmp
mkdir $4/binners/concoct/BINS


