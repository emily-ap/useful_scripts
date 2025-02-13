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

test -d dastool_${1}_out || mkdir -p dastool_${1}_out
test -d dastool_${1}_out/prepfiles || mkdir -p dastool_${1}_out/prepfiles

echo "Beginning to run DASTool on $1." 

## establish where the binners output bins are 

mkdir binning_out/binners/concoct/tmp_concoct_files
mkdir binning_out/binners/concoct/bin_tmp
mkdir binning_out/binners/concoct/BINS

# maxbin2 step 0 --> prepare the directories 

mkdir binning_out/binners/maxbin2/abundance
mkdir binning_out/binners/maxbin2/bins
mkdir binning_out/binners/maxbin2/bins/maxbin2_markerset40_bin


