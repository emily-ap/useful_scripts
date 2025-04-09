#script to run cross mapping 
## I'm trying to figure out how to make this to accomplish a few goals

# 0 - begin overarching project directory set up for mapping and binning after the assemblies have been organized by hand 
# 1 - generate a list of reads when given a read directory path and put into a file - readfile.txt 
# 2 - generate a list of contigs when given a contig directory path and put into a file 
# 3 - index it, map it - get sam output (we're just troublshooting this rn) 
# 4 - tell me when each step is done 

# to run: ./cross_mapping_with_minimap2.sh <read path> <contig path> <threads> <output dir> 
#         ./cross_mapping_with_minimap2.sh      1             2           3        4 
## I'd like to run this with flags instead of just ordered command line arguments, need to learn how to do this :) 

# to add once I've added flag options : make sure your contigs ends in .fa at your path!, make sure your fastqs are not gzipped and end in .fastq at your path

#### make directory structure - this is based on your contig file names (treats each contig as a sample name) 

mkdir $4
mkdir $4/crossmap_script_temp_dir
ls $2/*.fa >> crossmap_script_temp_dir/contig_paths.txt
ls $1/*.fastq >> crossmap_script_temp_dir/read_paths.txt
sed 's/.*\///' crossmap_script_temp_dir/contig_paths.txt >> crossmap_script_temp_dir/contig_IDs.txt
sed -i 's/.fa//' crossmap_script_temp_dir/contig_IDs.txt









 
#### make the read list



#### make the contig file 



#### index and run minimap2 (prep for parallel files)



#### make my parallel files - base each one on the contig file (i.e., one parallel file per contig) 








