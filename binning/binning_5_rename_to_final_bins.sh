S1/dastool_S1_out/final_out_S1_DASTool_bins


# run like this: ./binning_5_extract_dastool_bins.sh <full and final sample ID> <dastool OG bin output directory> <output directory> 
# ./binning_5_extract_dastool_bins.sh GB4_5264_sponge_S1 S1/dastool_S1_out/final_out_S1_DASTool_bins final_bin_set_not_derep
## slashes matter at end of directories: DO NOT USE THEM (please :) ) 

## outputs: new output directory, with bins and file of what the original bins were named

# 1 is sample ID 
# 2 is dastool output bins 
# 3 is desired output directory 

# rename bins

## get my list of bins 
ls ${2}/*.fa >> ${1}_1.txt
## begin formating list of bins 
sed -i 's/$/,/g' ${1}_1.txt

# make list of new names (2 files, one with bin numbers, one with bin prefix) 
iterate="$(ls ${2}/*.fa | wc -l)" 

## prefix
yes "${1}_Bin_" | head -n $iterate >> ${1}_2.txt

## bin numbers
seq 1 1 ${iterate} >> ${1}_3.txt
sed -i 's/$/.fna/g' ${1}_3.txt

## combine to get real list of new names
paste -d" " ${1}_2.txt ${1}_3.txt | while read from to; do echo mv "${from}" "${to}"; done >> ${1}_4.txt

## make final rename reference file 
paste -d" " ${1}_1.txt ${1}_4.txt | while read from to; do echo mv "${from}" "${to}"; done >> ${1}_rename.csv

## remove reference files to get renaming file 
rm ${1}_1.txt 
rm ${1}_2.txt
rm ${1}_3.txt
rm ${1}_4.txt

# start moving things to output location 
mkdir ${3}
mv ${1}_rename.csv ${3}











