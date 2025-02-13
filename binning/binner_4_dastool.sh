#!/bin/bash

### this is to be run once other binning scripts (binner_1-3) have been run. 
## requirements, dastool version, R (>v4, =v3 is good), pullseq, diamond or blastp
# This script will run DasTool using all the output bins from binners 1-3 (metabat2, maxbin2, concoct) 
# Run this in the directory where you're "binning_out" directory is!!!

#1 is your sample

#2 arg is your assembly 

#3 arg is path to your Fasta_to_Contig2Bin.sh script, if you're using miniconda it's probably something like this "/home/user/miniconda3/envs/dastool/bin/Fasta_to_Contig2Bin.sh" 

#4 arg is your max threadcount 

#5 your chosen search engine (usearch, diamond, blastp)

## first test if the output directory already exists and if not --> make it 

test -d dastool_${1}_out || mkdir -p dastool_${1}_out
test -d dastool_${1}_out/prepfiles || mkdir -p dastool_${1}_out/prepfiles

## establish where the binners output bins are 

concoctBins=binning_out/binners/concoct/BINS
maxbin2Bins=binning_out/binners/maxbin2/bins/maxbin2_markerset40_bin
metabat2Bins=binning_out/binners/metabat2

echo "Beginning to run DASTool on $1. Pulling bins from \n${concoctBins} , \n${maxbin2Bins} , \n${metabat2Bins}." 

## Let's start prepping the tsv files required for Dastool

maxbintsv=dastool_${1}_out/prepfiles/${1}-maxbin2_scaffold2bin.tsv
concocttsv=dastool_${1}_out/prepfiles/${1}-concoct_scaffold2bin.tsv
metabattsv=dastool_${1}_out/prepfiles/${1}-metabat2_scaffold2bin.tsv

$3 -e fna -i $maxbin2Bins > $maxbintsv &&
$3 -e fna -i $concoctBins > $concocttsv &&
$3 -e fna -i $metabat2Bins > $metabattsv &&
echo "Fasta_to_Scaffolds2Bin.sh is finished for sample ${1}!"

## run dastool 

DAS_Tool --score_threshold=0.5 -i $concocttsv,$maxbintsv,$metabattsv -l concoct,maxbin2,metabat2 -c $2 -o dastool/${1}-dastool_${5} --threads $4 --write_bins --search_engine $5





