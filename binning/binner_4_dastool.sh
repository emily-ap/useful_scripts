#!/bin/bash

### this is to be run once other binning scripts (binner_1-3) have been run. 
## requirements, dastool version, R (>v4, =v3 is good), pullseq, diamond or blastp
# This script will run DasTool using all the output bins from binners 1-3 (metabat2, maxbin2, concoct) 
# Run this in the directory where you're "binning_out" directory is!!!

#1 is your sample

#2 arg is your assembly 

#3 arg is path to your miniconda directory (i.e., something like /home/eaguilarpine/miniconda3) - do not end this in a slash!

#4 arg is your max threadcount 

## first test if the output directory already exists and if not --> make it 

test -d dastool_{$1}_out || mkdir -p binning_out
test -d binning_out/dastool_prepfiles || mkdir -p binning_out/dastool_prepfiles
mkdir binning_out/

echo "Beginning to run concoct on $1 with a min. contig size of $6 and using the assembly file: $2. Coverage files will be taken from the $3 directory and all results will be put in the generated binning_out directory." 

## establish where the binners output bins are 

mkdir binning_out/binners/concoct/tmp_concoct_files
mkdir binning_out/binners/concoct/bin_tmp
mkdir binning_out/binners/concoct/BINS


