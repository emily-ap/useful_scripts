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
mkdir binning_out/binners/maxbin2

echo "Beginning to run maxbin22 on $1 with a min. contig size of $6 and using the assembly file: $2. Coverage files will be taken from the $3 directory and all results will be put in the generated binning_out directory." 

## MAXBIN2 SECTION

# maxbin2 step 0 --> prepare the directories 

mkdir binning_out/binners/maxbin2/abundance
mkdir binning_out/binners/maxbin2/bins
mkdir binning_out/binners/maxbin2/bins/maxbin2_markerset40_bin

# maxbin2 step 1 --> makes the abundance files from the metabat2 depth file

maxbin_workdir=binning_out/binners/maxbin2
depthfile=binning_out/binners/metabat2/$1-depth.txt 
depthfile_ncol=$(awk -F'\t' '{print NF; exit}' ${depthfile}) 

seq 4 2 ${depthfile_ncol} | parallel --jobs $5 cut -f1,{} -d"$'\t'" $depthfile '|' tail -n +2 '>' ${maxbin_workdir}/abundance/abundance_file_{} && 

# maxbin2 step 2 --> uses the newly created abundance files to bin everything

# Create a file with a list of abundance file paths (the -abund_list used in the run_MaxBin.pl command)

find ${maxbin_workdir} -type f -name "abundance_file_*" > ${maxbin_workdir}/abundance/abund_list &&

# Run Maxbin2 with bacteria and archaea marker set (40 marker genes)

run_MaxBin.pl -contig $2 -out ${maxbin_workdir}/bins/maxbin2_markerset40_bin -abund_list ${maxbin_workdir}/abundance/abund_list -min_contig_length $6 -thread $5 -prob_threshold 0.9 -markerset 40 && 

echo "maxbin2 section has finished" 
